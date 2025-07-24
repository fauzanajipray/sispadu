import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sispadu/features/features.dart';
import 'package:sispadu/widgets/bottom_navigation_page.dart';

part 'destinations.dart';

class AppRouter {
  static final navigatorKey = GlobalKey<NavigatorState>();

  late final AuthCubit _authCubit;
  late final GoRouter _router;

  static final GlobalKey<NavigatorState> parentNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> homeTabNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> myReportTabNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> reportConfirmTabNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> settingTabNavigatorKey =
      GlobalKey<NavigatorState>();

  // final HomeRepository _homeRepository = HomeRepository();

  AppRouter(this._authCubit) {
    final routes = [
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: parentNavigatorKey,
        branches: [
          StatefulShellBranch(
            navigatorKey: homeTabNavigatorKey,
            routes: [
              GoRoute(
                path: Destination.homePath,
                pageBuilder: (context, GoRouterState state) {
                  return getPage(
                    child: MultiBlocProvider(
                      providers: [
                        BlocProvider(
                            create: (_) => ReportListBloc(ReportRepository())),
                      ],
                      child: const HomePage(),
                    ),
                    state: state,
                  );
                },
              ),
              GoRoute(
                path: Destination.createReportPath,
                pageBuilder: (context, GoRouterState state) {
                  return getPage(
                    child: MultiBlocProvider(
                      providers: [
                        BlocProvider(
                            create: (_) =>
                                ReportCreateCubit(ReportRepository())),
                        BlocProvider(
                            create: (_) =>
                                ReportUploadImageCubit(ReportRepository())),
                      ],
                      child: const ReportCreatePage(),
                    ),
                    state: state,
                  );
                },
              ),
              GoRoute(
                path: Destination.updateReportPath,
                pageBuilder: (context, GoRouterState state) {
                  final String? id = state.pathParameters['id'];
                  return getPage(
                    child: MultiBlocProvider(
                      providers: [
                        BlocProvider(
                            create: (_) =>
                                ReportCreateCubit(ReportRepository())),
                        BlocProvider(
                            create: (_) =>
                                ReportUploadImageCubit(ReportRepository())),
                        BlocProvider(
                            create: (_) => ReportCubit(ReportRepository())),
                      ],
                      child: ReportEditPage(id),
                    ),
                    state: state,
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: myReportTabNavigatorKey,
            routes: [
              GoRoute(
                path: Destination.myReportPath,
                pageBuilder: (context, GoRouterState state) {
                  return getPage(
                    child: MultiBlocProvider(
                      providers: [
                        BlocProvider(
                            create: (_) =>
                                MyReportListBloc(ReportRepository())),
                        // BlocProvider(
                        //     create: (_) =>
                        //         TopOutletListingBloc(_homeRepository)),
                        // BlocProvider(
                        //     create: (_) =>
                        //         CategoryPartnerCubit(_homeRepository))
                      ],
                      child: const HistoryPage(),
                    ),
                    state: state,
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: reportConfirmTabNavigatorKey,
            routes: [
              GoRoute(
                path: Destination.reportConfirmPath,
                pageBuilder: (context, GoRouterState state) {
                  return getPage(
                    child: const ConfirmationPage(), // Halaman belum dibuat
                    state: state,
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: settingTabNavigatorKey,
            routes: [
              GoRoute(
                path: Destination.settingPath,
                pageBuilder: (context, GoRouterState state) {
                  return getPage(
                    child: const SettingPage(),
                    state: state,
                  );
                },
              ),
            ],
          ),
        ],
        pageBuilder: (
          BuildContext context,
          GoRouterState state,
          StatefulNavigationShell navigationShell,
        ) {
          return getPage(
            child: BottomNavigationPage(
              child: navigationShell,
            ),
            state: state,
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: parentNavigatorKey,
        path: Destination.signInPath,
        pageBuilder: (context, state) {
          return getPage(
            child: const LoginScreen(),
            state: state,
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: parentNavigatorKey,
        path: Destination.signUpPath,
        pageBuilder: (context, state) {
          return getPage(
            child: const RegisterPage(),
            state: state,
          );
        },
      ),
      GoRoute(
        path: Destination.reportDetailPath,
        builder: (context, state) {
          final String? id = state.pathParameters['id'];
          return MultiBlocProvider(providers: [
            BlocProvider(create: (_) => ReportCubit(ReportRepository())),
            // BlocProvider(
            //     create: (_) => CompetitorReviewDeleteCubit(
            //         CompetitorReviewRepository())),
          ], child: ReportDetailPage(id));
        },
      ),
    ];

    _router = GoRouter(
      navigatorKey: parentNavigatorKey,
      initialLocation: Destination.homePath,
      refreshListenable: GoRouterRefreshStream(_authCubit.stream),
      routes: routes,
      redirect: (context, state) {
        final bool isAuthenticated =
            _authCubit.state.status == AuthStatus.authenticated &&
                _authCubit.state.token != "";

        final bool isUnauthenticated =
            _authCubit.state.status == AuthStatus.unauthenticated ||
                _authCubit.state.token == "";

        const nonAuthRoutes = [
          Destination.signInPath,
          Destination.signUpPath,
        ];

        const nonAuthRoutePublic = [
          Destination.homePath,
          Destination.myReportPath,
          Destination.reportConfirmPath,
          Destination.settingPath,
          Destination.reportDetailPath,
        ];

        // setelah main url, sub urlnya apa
        String? subloc = state.fullPath;
        // String fromRoutes = state.pathParameters['from'] ?? '';
        // print('route: $subloc, from: $fromRoutes, is Auth: $isAuthenticated, is UnAuth: $isUnauthenticated');

        // jika sudah authenticated

        if (isAuthenticated) {
          if (!nonAuthRoutes.contains(subloc)) {
            return null;
          } else {
            return Destination.homePath;
          }
        } else if (isUnauthenticated) {
          if (nonAuthRoutes.contains(subloc)) {
            return subloc;
          } else if (!nonAuthRoutePublic.contains(subloc)) {
            return Destination.homePath;
          }
        }
        return null;
      },
    );
  }

  static Page getPage({
    required Widget child,
    required GoRouterState state,
  }) {
    return MaterialPage(
      key: state.pageKey,
      child: child,
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
