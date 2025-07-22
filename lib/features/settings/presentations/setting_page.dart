import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:sispadu/features/features.dart';
import 'package:sispadu/helpers/dialog.dart';
import 'package:sispadu/services/routes/app_routes.dart';
import 'package:sispadu/widgets/custom_divider.dart';

// class SettingPage extends StatefulWidget {
//   const SettingPage({super.key});

//   @override
//   State<SettingPage> createState() => _SettingPageState();
// }

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      body: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, stateAuth) {},
          builder: (context, stateAuth) {
            bool isAuthenticated =
                stateAuth.status == AuthStatus.authenticated &&
                    stateAuth.token != "";
            return SingleChildScrollView(
              child: Column(children: [
                Container(
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Theme.of(context).colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 40,
                        // offset: const Offset(0, 25),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      if (!isAuthenticated)
                        Column(
                          children: [
                            ListTile(
                              title: Row(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color: Colors.blue,
                                    ),
                                    child: const Icon(
                                      Icons.logout,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const Text('Login'),
                                ],
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              trailing: const Icon(Icons.keyboard_arrow_right),
                              onTap: () {
                                context.push(Destination.signInPath);
                              },
                            ),
                            const CustomDivider(),
                          ],
                        ),
                      if (isAuthenticated)
                        Column(
                          children: [
                            ListTile(
                              title: Row(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color: Colors.blue,
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const Text('Profile'),
                                ],
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              trailing: const Icon(Icons.keyboard_arrow_right),
                              onTap: () {
                                // context.push(Destination.profilePath);
                              },
                            ),
                            const CustomDivider(),
                          ],
                        ),
                      // _buildThemeCard(),
                      if (isAuthenticated)
                        Column(
                          children: [
                            const CustomDivider(),
                            ListTile(
                              title: Row(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color: Colors.red,
                                    ),
                                    child: const Icon(
                                      Icons.logout,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'Logout',
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.error,
                                    ),
                                  ),
                                ],
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              trailing: const Icon(Icons.keyboard_arrow_right),
                              onTap: () {
                                showDialogConfirmation(
                                  context,
                                  () {
                                    context
                                        .read<AuthCubit>()
                                        .setUnauthenticated();
                                    // context
                                    //     .read<OtpResend>()
                                    //     .add(DeleteStateEvent());
                                    context
                                        .read<ProfileCubit>()
                                        .deleteDataProfile();
                                    OneSignal.logout();
                                    OneSignal.User.removeAlias("type");
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("You're logout!"),
                                      ),
                                    );
                                  },
                                  message: 'Are you sure want to logout?',
                                );
                              },
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ]),
            );
          }),
    );
  }
}
