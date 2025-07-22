import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:logger/web.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:sispadu/constant/app_color.dart';
import 'package:sispadu/constant/app_constant.dart';
import 'package:sispadu/features/features.dart';
import 'package:sispadu/services/dio_client.dart';
import 'package:sispadu/services/routes/app_routes.dart';
import 'package:sispadu/utils/dio_exceptions.dart';

import 'widgets/widgets.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  final storage = await HydratedStorage.build(
      storageDirectory: kIsWeb
          ? HydratedStorage.webStorageDirectory
          : await getApplicationDocumentsDirectory());
  HydratedBloc.storage = storage;
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await initializeDateFormatting('id_ID', null);
  await dotenv.load(fileName: ".env");
  AppConstant();

  runApp(const MainApp());
}

Logger logger = Logger(printer: PrettyPrinter());

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final AuthRepository _authRepository = AuthRepository();
  late DioClient dioClient;
  late final AuthCubit _authCubit = AuthCubit();
  // late final SettingBloc _settingBloc = SettingBloc(SettingRepository());
  late final ThemeBloc _themeBloc = ThemeBloc();
  late final GoRouter _router;
  late BuildContext storedContext;
  late AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    dioClient = DioClient(authCubit: _authCubit);
    dioClient.init();
    _router = AppRouter(_authCubit).router;
    Future.delayed(Duration.zero, () {
      initAsyncData();
    });
    initPlatformState();
    initDeepLinks();
  }

  void initAsyncData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authCubit.checkToken();
      // if (mounted) {
      //   _settingBloc.add(GetDataSetting());
      // }
    });
  }

  Future<void> initDeepLinks() async {
    if (!kIsWeb) {
      _appLinks = AppLinks();

      // Handle links
      _appLinks.uriLinkStream.listen((uri) {
        var router = uri.queryParameters['route'];
        if (router != null) {
          if (router != '') {
            _router.go(router);
            return;
          }
        }
        _router.go(Destination.homePath);
      });
    }
  }

  Future<void> initPlatformState() async {
    // OneSignal.Notifications.addClickListener((result) {
    //   Map<String, dynamic>? additionalData = result.notification.additionalData;
    //   logger.e(additionalData);
    //   if (additionalData != null) {
    //     String url = (additionalData['route'] as String?) ?? '';
    //     logger.e(url);
    //     if (url != '') {
    //       _router.go(url);
    //       return;
    //     }
    //   }
    //   _router.go(Destination.home);
    // });
    if (Platform.isAndroid) {
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
      OneSignal.initialize(AppConstant.oneSignalAppKey);
      OneSignal.Notifications.requestPermission(true);
    }
  }

  @override
  Widget build(Object context) {
    return RepositoryProvider(
        create: (context) => _authRepository,
        child: MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => _authCubit),
            BlocProvider(create: (_) => _themeBloc),
            BlocProvider(create: (_) => ProfileCubit(_authRepository)),
          ],
          child: buildMaterialApp(_router),
        ));
  }

  Widget buildMaterialApp(GoRouter router) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        ThemeMode themeMode = ThemeMode.light;
        if (state.isThemeSystem) {
          themeMode = ThemeMode.system;
        } else {
          if (state.isThemeLight) {
            themeMode = ThemeMode.light;
          } else {
            themeMode = ThemeMode.dark;
          }
        }
        return MaterialApp.router(
          title: AppConstant.appName,
          debugShowCheckedModeBanner: false,
          routeInformationProvider: _router.routeInformationProvider,
          routeInformationParser: _router.routeInformationParser,
          routerDelegate: _router.routerDelegate,
          builder: (context, child) {
            storedContext = context;
            return BlocBuilder<AuthCubit, AuthState>(
              buildWhen: (previous, current) {
                return previous.status != current.status;
              },
              builder: (BuildContext context, AuthState state) {
                FlutterNativeSplash.remove();
                if (state.status == AuthStatus.initial ||
                    state.status == AuthStatus.loading) {
                  return Scaffold(
                    body: const LoadingProgress(),
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainer,
                  );
                } else if (state.status == AuthStatus.failure ||
                    state.status == AuthStatus.reloading) {
                  return LoginErrorScreen(
                      DioExceptions.fromDioError(state.error!, context)
                          .toString());
                }
                dioClient.init();
                return ResponsiveBreakpoints.builder(
                  child: child!,
                  breakpoints: [
                    const Breakpoint(start: 0, end: 450, name: MOBILE),
                    const Breakpoint(start: 451, end: 800, name: TABLET),
                    const Breakpoint(start: 801, end: 1920, name: DESKTOP),
                  ],
                );
              },
            );
          },
          theme: theme,
          darkTheme: themeDark,
          themeMode: themeMode,
        );
      },
    );
  }

  ThemeData get theme => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColor.primaryColor,
          primary: AppColor.primaryColor,
          onPrimary: AppColor.onPrimaryColor,
          secondary: AppColor.secondaryColor,
          onSecondary: AppColor.onSecondaryColor,
          tertiary: AppColor.tertiaryColor,
          onSurfaceVariant: Colors.grey,
          error: AppColor.errorColor,
          surface: AppColor.surfaceColor,
          surfaceContainer: Color.fromARGB(
            255,
            (255 * 0.95 + AppColor.primaryColor.red * 0.05)
                .toInt(), // Primary lebih sedikit
            (255 * 0.95 + AppColor.primaryColor.green * 0.05).toInt(),
            (255 * 0.95 + AppColor.primaryColor.blue * 0.05).toInt(),
          ),
          outline: AppColor.dividerColor,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColor.secondaryColor,
          foregroundColor: AppColor.onSecondaryColor,
        ),
        drawerTheme: const DrawerThemeData(
          backgroundColor: AppColor.surfaceColor,
        ),
        dialogTheme: const DialogTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(16),
            ),
          ),
        ),
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
        ),
        useMaterial3: true,
        cardTheme: const CardTheme(
          color: Color.fromRGBO(255, 255, 255, 1),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: ButtonStyle(
            iconColor: WidgetStateProperty.all(AppColor.iconColor),
          ),
        ),
        dividerColor: AppColor.dividerColor,
      );

  ThemeData get themeDark => ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark(
          primary: AppColor.primaryColor,
          onPrimary: AppColor.surfaceColor,
          secondary: AppColor.secondaryColor,
          // tertiary: AppColor.tertiaryColor,
          // onSurfaceVariant: Colors.grey,
          error: AppColor.errorColor,
          onError: AppColor.surfaceColor,
          surface: Color.fromARGB(
            AppColor.primaryColor.alpha,
            (AppColor.primaryColor.red * 0.2 + Colors.black.red * 0.8).toInt(),
            (AppColor.primaryColor.green * 0.2 + Colors.black.green * 0.8)
                .toInt(),
            (AppColor.primaryColor.blue * 0.2 + Colors.black.blue * 0.8)
                .toInt(),
          ),
          onSurface: AppColor.surfaceColor,
          surfaceContainer: Color.fromARGB(
            AppColor.primaryColor.alpha,
            (AppColor.primaryColor.red * 0.05 + Colors.black.red * 0.8).toInt(),
            (AppColor.primaryColor.green * 0.05 + Colors.black.green * 0.8)
                .toInt(),
            (AppColor.primaryColor.blue * 0.05 + Colors.black.blue * 0.8)
                .toInt(),
          ),
        ),
        dialogTheme: DialogTheme(
          backgroundColor: Color.fromARGB(
              AppColor.primaryColor.alpha,
              (AppColor.primaryColor.red * 0.2 + Colors.black.red * 0.8)
                  .toInt(),
              (AppColor.primaryColor.green * 0.2 + Colors.black.green * 0.8)
                  .toInt(),
              (AppColor.primaryColor.blue * 0.2 + Colors.black.blue * 0.8)
                  .toInt()),
          elevation: 0.5,
          surfaceTintColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(16),
            ),
          ),
        ),
      );
}
