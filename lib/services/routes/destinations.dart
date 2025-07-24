part of 'app_routes.dart';

class Destination {
  static const String signInPath = '/login';
  static const String signUpPath = '/register';

  static const String homePath = '/home';
  static const String createReportPath = '/create-report';
  static const String updateReportPath = '/create-report/:id';

  static const String myReportPath = '/my-report';

  static const String reportDetailPath = '/report/:id';
  static const String reportConfirmPath = '/report-confirm';

  static const String settingPath = "/setting";
  static const String settingNoAuthPath = "/setting-noauth";
}
