import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:sispadu/helpers/dialog.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../main.dart';
import '../utils/dio_exceptions.dart';

String capitalize(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}

String capitalizeEach(String text) {
  return text.split(' ').map((word) => capitalize(word)).join(' ');
}

String extractErrorMessage(dynamic error) {
  if (error is DioException && error.response != null) {
    try {
      final Map<String, dynamic> jsonResponse =
          jsonDecode(error.response.toString());
      var errorMessage = jsonResponse["error"];
      errorMessage ??= jsonResponse["message"];
      return errorMessage ?? "An error occurred";
    } catch (e) {
      return "An error occurred";
    }
  } else {
    return "An error occurred";
  }
}

String? extractErrorMessageFromError(List<String>? errorsMsg) {
  if (errorsMsg != null) {
    if (errorsMsg.isNotEmpty) {
      return errorsMsg.first;
    } else {
      return null;
    }
  } else {
    return null;
  }
}

Map<String, dynamic> convertDotNotationToMap(Map<String, dynamic> errors) {
  Map<String, dynamic> result = {};

  errors.forEach((key, value) {
    final parts = key.split('.');
    if (parts.length > 1) {
      if (result[parts[0]] == null) {
        result[parts[0]] = {};
      }
      if (result[parts[0]][parts[1]] == null) {
        result[parts[0]][parts[1]] = {};
      }
      result[parts[0]][parts[1]][parts[2]] = value;
    } else {
      result[key] = value;
    }
  });

  return result;
}

Future<File?> getImage(
    BuildContext context, ImageSource imageSource, ImagePicker picker) async {
  try {
    var permission = PermissionStatus.granted;
    if (Platform.isAndroid) {
      if (imageSource == ImageSource.camera) {
        permission = await requestCameraPermissions(context);
      }
    }
    XFile? imageFile;
    if (permission.isGranted) {
      imageFile = await picker.pickImage(source: imageSource, imageQuality: 80);
      if (imageFile != null) {
        if (!context.mounted) return null;
        CroppedFile? croppedImage = await cropImage(context, imageFile);
        if (croppedImage != null) {
          return File(croppedImage.path);
        }
      } else {
        logger.e('Image null');
      }
    } else {
      logger.e('Something went wrong! , $permission');
    }
  } catch (e) {
    if (!context.mounted) return null;
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('Permission Denied'),
          content: const Text('Allow access to gallery and photos'),
          actions: [
            CupertinoDialogAction(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop()),
            CupertinoDialogAction(
                onPressed: () => openAppSettings(),
                isDefaultAction: true,
                child: const Text('Settings')),
          ],
        ),
      );
    }
  }
  return null;
}

Future<CroppedFile?> cropImage(BuildContext context, XFile file) async {
  if (!context.mounted) return null; // Check if the widget is still mounted
  final localContext = context; // Store the context locally
  CroppedFile? croppedFile = await ImageCropper().cropImage(
    sourcePath: file.path,
    // aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
    compressFormat: ImageCompressFormat.png,
    maxWidth: 800,
    maxHeight: 800,
    compressQuality: 80,
    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: 'Crop the image',
        toolbarColor: Theme.of(localContext).colorScheme.primary,
        toolbarWidgetColor: Theme.of(localContext).colorScheme.onPrimary,
      ),
      IOSUiSettings(
        title: 'Crop the image',
        aspectRatioPickerButtonHidden: true,
        resetButtonHidden: true,
        aspectRatioLockDimensionSwapEnabled: true,
        aspectRatioLockEnabled: true,
      ),
      WebUiSettings(
        context: localContext,
      ),
    ],
  );

  if (!context.mounted) return null; // Check again after the async operation

  return croppedFile;
}

Future<PermissionStatus> requestCameraPermissions(BuildContext context) async {
  final status = await Permission.camera.request();
  if (status.isPermanentlyDenied || status.isDenied) {
    if (context.mounted) {
      showAdaptiveDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Permission Required"),
            content: const Text(
                "To use this feature, please enable the camera permission in your device's settings."),
            actions: <Widget>[
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  openAppSettings(); // Open app settings
                },
              ),
            ],
          );
        },
      );
    }
  }
  return status;
}

String concatAllMappedMessage(Map<String, List<String>>? mappedMessage) {
  List<String> finalMessage = [];
  if (mappedMessage != null) {
    mappedMessage.forEach((key, messages) {
      finalMessage.add(messages.join("\n"));
    });
  }
  return finalMessage.join("\n");
}

void showDialogConfirmationDelete(BuildContext mainContext, Function onDelete,
    {String title = 'Confirmation',
    String message = 'Are you sure you want to delete this data?',
    String errorBtn = 'Delete'}) {
  showAdaptiveDialog(
    context: mainContext,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDelete();
            },
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error),
            child: Text(errorBtn),
          ),
        ],
      );
    },
  );
}

String formatCurrency(dynamic number) {
  if (number is int) {
    return NumberFormat().format(number).replaceAll(',', '.');
  } else if (number is double) {
    return NumberFormat()
        .format(number)
        .replaceAll(',', 'X')
        .replaceAll('.', ',')
        .replaceAll('X', '.');
  } else {
    return '0';
  }
}

String formatDateTimeCustom(DateTime? dateTime,
    {String format = 'EEEE, d MMM yyyy', String ifnull = '-'}) {
  if (dateTime == null) {
    return ifnull;
  } else {
    final DateFormat formatter =
        DateFormat(format, "id_ID"); // indonesia -> id_ID
    return formatter.format(dateTime);
  }
}

bool isLeapYear(int year) {
  if (year % 4 != 0) {
    return false;
  } else if (year % 100 != 0) {
    return true;
  } else if (year % 400 != 0) {
    return false;
  } else {
    return true;
  }
}

String getErrorMessage(BuildContext context,
    {DioException? error,
    bool with422 = true,
    String? defaultMessage,
    String? error422,
    conte}) {
  var exception = error;
  var message = defaultMessage ?? "Failed to connect to the server.";
  if (exception != null) {
    message = DioExceptions.fromDioError(exception, context).toString();
    if (with422) {
      Map<String, List<String>>? mappedMessage =
          DioExceptions.fromDioError422(exception, context).mappedMessage;
      String finalMessage = concatAllMappedMessage(mappedMessage);
      if (finalMessage.isNotEmpty) {
        if (error422 != null) {
          message = error422;
        } else {
          message = finalMessage;
        }
      }
    }
  }
  return message;
}

Future<Map<String, dynamic>> loadJsonFromAssets(String path) async {
  String jsonString = await rootBundle.loadString(path);
  return json.decode(jsonString);
}

void handleErrorList(BuildContext context, DioException? dioError) {
  var statusCode = dioError?.response?.statusCode;
  if (dioError != null) {
    var e = DioExceptions.fromDioError(dioError, context);
    if (dioError.type != DioExceptionType.badResponse) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
        ),
      );
    } else {
      if (statusCode != 422) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
          ),
        );
      } else {
        Map<String, List<String>>? mappedMessage =
            DioExceptions.fromDioError422(dioError, context).mappedMessage;
        String finalMessage = concatAllMappedMessage(mappedMessage);
        showDialogInfo(context, () {}, message: finalMessage);
      }
    }
  }
}

showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    ),
  );
}

Map<String, Color> generateRandomColors() {
  Random random = Random();

  // Generate random background color
  Color backgroundColor = Color.fromARGB(
    255, // Full opacity
    random.nextInt(256), // Red (0-255)
    random.nextInt(256), // Green (0-255)
    random.nextInt(256), // Blue (0-255)
  );

  // Generate contrasting text color based on background color
  Color textColor = (backgroundColor.computeLuminance() > 0.5)
      ? Colors.black // Light background, use dark text
      : Colors.white; // Dark background, use light text

  return {
    'backgroundColor': backgroundColor,
    'textColor': textColor,
  };
}

void clearCookiesWeb() async {
  final cookieManager = WebViewCookieManager();
  await cookieManager.clearCookies();
  if (kDebugMode) {
    print('Cookies cleared');
  }
}

Color? getTextColorPrimary(BuildContext context) {
  bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
  return isDarkMode ? Colors.white : Theme.of(context).colorScheme.primary;
}

bool isDarkMode(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark;
}
