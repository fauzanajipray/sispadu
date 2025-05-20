import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';

class LoginErrorScreen extends StatelessWidget {
  final String errorMessage;
  final int statusCode;

  const LoginErrorScreen(String? message, this.statusCode, {super.key})
      : errorMessage = message ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Authentication Error'),
      // ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/images/ic-error.png',
                width: 86,
              ),
              const SizedBox(height: 16.0),
              Text(
                statusCode == 423
                    ? 'Account Suspended'
                    : 'Authentication Error',
                style: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  errorMessage,
                  style: const TextStyle(fontSize: 16.0),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      // You can add logic here to handle the error or navigate back
                      // Navigator.of(context).pop();
                      await context.read<AuthCubit>().checkToken();
                    },
                    child: const Text('Retry'),
                  ),
                  Visibility(
                    visible: context.read<AuthCubit>().state.token != '',
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary),
                        onPressed: () async {
                          // You can add logic here to handle the error or navigate back
                          context.read<AuthCubit>().setUnauthenticated();
                        },
                        child: const Text('Logout'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
