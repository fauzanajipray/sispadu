import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';

class LoginErrorScreen extends StatelessWidget {
  final String errorMessage;

  const LoginErrorScreen(String? message, {super.key})
      : errorMessage = message ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Authentication Error'),
      // ),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.error,
              color: Colors.red,
              size: 48.0,
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Authentication Error',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              errorMessage,
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                // You can add logic here to handle the error or navigate back
                // Navigator.of(context).pop();
                await context.read<AuthCubit>().checkToken();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
