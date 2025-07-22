import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:sispadu/features/auth/cubit/auth_cubit.dart';
import 'package:sispadu/features/auth/cubit/auth_state.dart';
import 'package:sispadu/services/routes/app_routes.dart';
import 'package:sispadu/widgets/my_button.dart';

Widget containerErrorLogin(BuildContext context,
    {String? route = Destination.homePath}) {
  return BlocBuilder<AuthCubit, AuthState>(
    builder: (context, stateAuth) {
      if (stateAuth.status == AuthStatus.unauthenticated) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: SizedBox(
                  child: Center(
                    child: Lottie.asset(
                      'assets/lottie/animation_need_login.json',
                      repeat: true,
                      reverse: true,
                    ),
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 16, top: 16),
              child: Text(
                'Please login to access this page',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(
              width: 150,
              height: 40,
              child: MyButton(
                verticalPadding: 0,
                onPressed: () {
                  context.push(Destination.signInPath);
                },
                text: 'Login',
              ),
            ),
            const SizedBox(height: 60),
          ],
        );
      } else {
        return Container();
      }
    },
  );
}
