import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sispadu/features/auth/auth.dart';
import 'package:sispadu/utils/data_state.dart';

class BottomNavigationPage extends StatefulWidget {
  const BottomNavigationPage({
    super.key,
    required this.child,
  });

  final StatefulNavigationShell child;
  @override
  State<BottomNavigationPage> createState() => _BottomNavigationPageState();
}

class _BottomNavigationPageState extends State<BottomNavigationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      // backgroundColor: Theme.of(context).colorScheme.error,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      body: SafeArea(
        child: widget.child,
      ),
      bottomNavigationBar: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {},
          builder: (context, state) {
            return BlocBuilder<ProfileCubit, DataState<User>>(
                builder: (context, stateProfile) {
              final bool isAuthenticated =
                  state.status == AuthStatus.authenticated && state.token != "";
              User? user = stateProfile.item;
              final bool showConfirmationTab =
                  isAuthenticated && user?.position != null;

              // Memetakan branch index dari GoRouter ke visual index di BottomNavigationBar.
              int calculateVisualIndex(int branchIndex) {
                // Tab konfirmasi ada di branch index 2. Jika disembunyikan,
                // index visual tab setelahnya akan bergeser.
                if (!showConfirmationTab && branchIndex > 1) {
                  return branchIndex - 1;
                }
                return branchIndex;
              }

              // Memetakan visual index dari BottomNavigationBar kembali ke branch index GoRouter.
              int calculateBranchIndex(int visualIndex) {
                if (!showConfirmationTab && visualIndex > 1) {
                  return visualIndex + 1;
                }
                return visualIndex;
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Divider(
                    height: 1, // Ketebalan border
                    color: Theme.of(context).dividerColor, // Warna border
                  ),
                  BottomNavigationBar(
                    type: BottomNavigationBarType.shifting,
                    currentIndex:
                        calculateVisualIndex(widget.child.currentIndex),
                    selectedItemColor: Theme.of(context).colorScheme.onSurface,
                    unselectedItemColor: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                    onTap: (index) {
                      final destinationIndex = calculateBranchIndex(index);
                      widget.child.goBranch(destinationIndex,
                          initialLocation:
                              destinationIndex == widget.child.currentIndex);
                    },
                    items: [
                      BottomNavigationBarItem(
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        icon: const Icon(Icons.home),
                        label: 'Home',
                      ),
                      BottomNavigationBarItem(
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        icon: const Icon(Icons.history),
                        label: 'History',
                      ),
                      if (showConfirmationTab)
                        BottomNavigationBarItem(
                          backgroundColor:
                              Theme.of(context).colorScheme.surface,
                          icon: const Icon(Icons.dashboard),
                          label: 'Confirmation',
                        ),
                      BottomNavigationBarItem(
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        icon: const Icon(Icons.menu),
                        label: 'Setting',
                      ),
                    ],
                  ),
                ],
              );
            });
          }),
    );
  }
}
