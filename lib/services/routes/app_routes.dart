import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sispadu/features/features.dart';

part 'destinations.dart';

class AppRouter {
  static final navigatorKey = GlobalKey<NavigatorState>();

  late final AuthCubit _authCubit;
  late final GoRouter _router;

  // final HomeRepository _homeRepository = HomeRepository();

  AppRouter(this._authCubit) {
    _router = GoRouter(
      navigatorKey: navigatorKey,
      // errorBuilder: ((context, state) {
      //   return const ErrorNotFoundPage();
      // }),
      initialLocation: Destination.home,
      refreshListenable: GoRouterRefreshStream(_authCubit.stream),
      redirect: (context, state) {
        final bool isAuthenticated =
            _authCubit.state.status == AuthStatus.authenticated &&
                _authCubit.state.token != "";

        final bool isUnauthenticated =
            _authCubit.state.status == AuthStatus.unauthenticated ||
                _authCubit.state.token == "";
        // const routeValidateOtp = '/otp-login';

        const nonAuthRoutes = [
          '/login',
          Destination.settingNoAuth,
          // '/forgot-password'
        ];

        // setelah main url, sub urlnya apa
        String? subloc = state.fullPath;

        // params from
        String fromRoutes = state.pathParameters['from'] ?? '';

        // jika akses /login tapi ternyata sudah authenticated
        if (nonAuthRoutes.contains(subloc) && isAuthenticated) {
          // ini ngembaliin ke halaman yang diinginkan setelah login
          if (fromRoutes.isNotEmpty) {
            return fromRoutes;
          }
          // defaultnya ke dashboard
          return '/home';
        } else if (!nonAuthRoutes.contains(subloc) && isUnauthenticated) {
          return '/login?from=${state.fullPath}';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          redirect: (context, state) => Destination.home,
          builder: (context, state) => const SizedBox.shrink(),
        ),
        GoRoute(
          name: 'Home',
          path: Destination.home,
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: Destination.login,
          builder: (context, state) => const LoginScreen(),
        ),
      ],
    );
  }

  GoRouter get router => _router;
}

class GoRouterRefreshStream extends ChangeNotifier {
  /// Creates a [GoRouterRefreshStream].
  ///
  /// Every time the [stream] receives an event the [GoRouter] will refresh its
  /// current route.
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
