import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppColor {
  static Color get primaryColor => _getColorFromEnv('PRIMARY_COLOR');
  static Color get secondaryColor => _getColorFromEnv('SECONDARY_COLOR');
  static Color get tertiaryColor => _getColorFromEnv('TERTIARY_COLOR');
  // static const Color primaryColor = Color.fromARGB(255, 113, 71, 2);
  // static const Color secondaryColor = Color.fromARGB(255, 184, 135, 36);
  // // static const Color tertiaryColor = Color.fromARGB(255, 77, 77, 77); // #4D4D4D
  // static const Color tertiaryColor =
  //     Color.fromARGB(255, 235, 215, 190); // #EBD7BE

  static const Color errorColor = Color(0xFFEE1200);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color textColor = Color(0xFF101116);
  static const Color disabledColor = Color(0xFF999999);
  static const Color dividerColor = Color(0xFFD1D1D1);
  static const Color iconColor = Color(0xFFBDBDBD);

  // Other colors
  static const Color successColor = Color(0xFF009956);
  static const Color warningColor = Color(0xFFe0c800);

  static Color get onSecondaryColor {
    return secondaryColor.computeLuminance() > 0.5
        ? textColor // Warna terang, gunakan hitam
        : Colors.white; // Warna gelap, gunakan putih
  }

  static Color get onPrimaryColor {
    return primaryColor.computeLuminance() > 0.5
        ? textColor // Warna terang, gunakan hitam
        : Colors.white; // Warna gelap, gunakan putih
  }

  static Color _getColorFromEnv(String key) {
    final colorValue = dotenv.env[key];
    if (colorValue == null) {
      throw Exception('Missing color value for $key in .env file');
    }

    final parts =
        colorValue.split(',').map((e) => int.parse(e.trim())).toList();
    if (parts.length != 3) {
      throw Exception('Invalid color format for $key. Use "R,G,B".');
    }

    return Color.fromARGB(255, parts[0], parts[1], parts[2]);
  }
}
