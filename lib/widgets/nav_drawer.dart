import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../features/auth/cubit/auth_cubit.dart';
import '../services/routes/app_routes.dart';

class NavigationDrawerSection extends StatefulWidget {
  const NavigationDrawerSection(this.mainContext, this.routeNow, {super.key});
  final BuildContext mainContext;
  final String routeNow;
  @override
  State<NavigationDrawerSection> createState() =>
      _NavigationDrawerSectionState();
}

class _NavigationDrawerSectionState extends State<NavigationDrawerSection> {
  int screenIndex = 0;
  int indexLogout = 1;
  late bool showNavigationDrawer;
  List<NavDestination> filteredDestinations = [];

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   reset(context.read<SettingBloc>().state);
    // });
    indexLogout = destinations.length;
  }

  void handleScreenChanged(int selectedScreen) {
    if (indexLogout == selectedScreen) {
      widget.mainContext.read<AuthCubit>().setUnauthenticated();
      if (Platform.isAndroid) {
        OneSignal.logout();
        OneSignal.User.removeAlias("type");
      }
      // widget.mainContext.read<Cart2Bloc>().add(ClearCartEvent());
    } else {
      setState(() {
        screenIndex = selectedScreen;
      });
      widget.mainContext.go(filteredDestinations[selectedScreen].route);
      Navigator.of(context).pop();
    }
  }

  // void reset(SettingState settingState) {
  //   bool isAdmin = settingState.isAdminRole;
  //   // Filter the destinations based on isAdmin status
  //   List<NavDestination> filteredDestinationsNow =
  //       destinations.where((destination) {
  //     // Show 'Summary' and 'Schedule' only for admin
  //     if ((destination.route == Destination.productSummary ||
  //             destination.route == Destination.schedule ||
  //             destination.route == Destination.webviewAdminPath) &&
  //         !isAdmin) {
  //       return false; // Hide these if the user is not an admin
  //     }

  //     if (destination.route == Destination.booking &&
  //         !settingState.bookingFeature) {
  //       return false;
  //     }

  //     if (destination.route == Destination.customer &&
  //         !settingState.customerFeature) {
  //       return false;
  //     }

  //     if (destination.route == Destination.discount &&
  //         !settingState.discountFeature) {
  //       return false;
  //     }
  //     if (destination.route == Destination.promo &&
  //         !settingState.promoFeature) {
  //       return false;
  //     }
  //     if (destination.route == Destination.stock &&
  //         !settingState.stockFeature) {
  //       return false;
  //     }
  //     if (destination.route == Destination.events &&
  //         !settingState.eventFeature) {
  //       return false;
  //     }
  //     return true;
  //   }).toList();

  //   setState(() {
  //     filteredDestinations = filteredDestinationsNow;
  //     screenIndex = findDestinationIndex(widget.routeNow);
  //     indexLogout = filteredDestinationsNow.length;
  //   });
  // }

  int findDestinationIndex(String route) {
    return filteredDestinations
        .indexWhere((destination) => destination.route == route);
  }

  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(
      onDestinationSelected: handleScreenChanged,
      selectedIndex: screenIndex,
      backgroundColor: Theme.of(context).colorScheme.surface,
      children: <Widget>[
        const SizedBox(height: 20),
        Padding(
            padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
            child: Text(
              'Menu',
              style: Theme.of(context).textTheme.titleSmall,
            )),
        ...destinations.map((destination) {
          return NavigationDrawerDestination(
              label: Text(
                destination.label,
                // style: TextStyle(
                //   color: Theme.of(context)
                //       .colorScheme
                //       .onSecondary
                //       .withOpacity(0.5),
                // ),
              ),
              icon: Icon(destination.icon),
              selectedIcon: Icon(destination.selectedIcon));
        }),
        const Divider(indent: 28, endIndent: 28),
        const NavigationDrawerDestination(
            icon: Icon(Icons.logout_outlined),
            label: Text('Logout'),
            selectedIcon: Icon(Icons.logout))
      ],
    );
    /*
    return BlocConsumer<SettingBloc, SettingState>(
      listener: (context, state) => reset(state),
      builder: (context, state) {
        return NavigationDrawer(
          onDestinationSelected: handleScreenChanged,
          selectedIndex: screenIndex,
          backgroundColor: Theme.of(context).colorScheme.surface,
          // indicatorColor: Theme.of(context).colorScheme.secondary,
          children: <Widget>[
            const SizedBox(height: 20),
            Padding(
                padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
                child: Text(
                  'Menu',
                  style: Theme.of(context).textTheme.titleSmall,
                )),
            ...filteredDestinations.map((destination) {
              return NavigationDrawerDestination(
                  label: Text(
                    destination.label,
                    // style: TextStyle(
                    //   color: Theme.of(context)
                    //       .colorScheme
                    //       .onSecondary
                    //       .withOpacity(0.5),
                    // ),
                  ),
                  icon: Icon(destination.icon),
                  selectedIcon: Icon(destination.selectedIcon));
            }),
            const Divider(indent: 28, endIndent: 28),
            const NavigationDrawerDestination(
                icon: Icon(Icons.logout_outlined),
                label: Text('Logout'),
                selectedIcon: Icon(Icons.logout))
          ],
        );
      },
    );
    */
  }
}

class NavDestination {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String route;
  final NavDestination? child;

  const NavDestination(
    this.label,
    this.icon,
    this.selectedIcon,
    this.route, {
    this.child,
  });
}

const List<NavDestination> destinations = <NavDestination>[
  NavDestination('Home', Icons.home_outlined, Icons.home, Destination.home),
  NavDestination(
      'Settings', Icons.settings_outlined, Icons.settings, Destination.setting),
];
