import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sispadu/features/features.dart';
import 'package:sispadu/utils/utils.dart';
import 'package:sispadu/widgets/contaianer_error_login.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(builder: (context, stateAuth) {
      bool isAuthenticated =
          stateAuth.status == AuthStatus.authenticated && stateAuth.token != "";
      if (isAuthenticated) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('History'),
          ),
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          body: _buildViews(context),
        );
      }
      return Scaffold(
        appBar: AppBar(
          title: const Text('History'),
        ),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        body: containerErrorLogin(context),
      );
    });
  }

  Widget _buildViews(BuildContext context) {
    return BlocBuilder<ProfileCubit, DataState<User>>(
        builder: (context, stateProfile) {
      return Container(
        child: Text(stateProfile.item?.toRawJson() ?? '--'),
      );
    });
  }
}
