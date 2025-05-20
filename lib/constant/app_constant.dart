import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstant {
  AppConstant() {
    assert(dotenv.env['BASE_URL'] != null && dotenv.env['BASE_URL']!.isNotEmpty,
        'BASE_URL is not set or is empty in the environment variables');
    assert(
        dotenv.env['ONE_SIGNAL_APP_KEY'] != null &&
            dotenv.env['ONE_SIGNAL_APP_KEY']!.isNotEmpty,
        'ONE_SIGNAL_APP_KEY is not set or is empty in the environment variables');
    assert(dotenv.env['APP_NAME'] != null && dotenv.env['APP_NAME']!.isNotEmpty,
        'APP_NAME is not set or is empty in the environment variables');
  }

  static String get baseUrl => '${dotenv.env['BASE_URL']}api/';
  static String get oneSignalAppKey => dotenv.env['ONE_SIGNAL_APP_KEY']!;
  static String get appName => dotenv.env['APP_NAME']!;

  static const int apiReceiveTimeout = 30000;
  static const int apiSendTimeout = 15000;
  static const int apiConnectionTimeout = 30000;

  static const double screenMobile = 480;
  static const double screenTablet = 800;
  static const double screenDesktop = 1024;
}
