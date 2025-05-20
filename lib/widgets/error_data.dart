import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sispadu/helpers/helpers.dart';

import '../utils/dio_exceptions.dart';

Widget errorData(BuildContext context, DioException? error,
    {Function()? onRetry,
    CrossAxisAlignment? crossAxisAlignment,
    bool with422 = true,
    String? defaultMessage,
    String? error422}) {
  var exception = error;
  var message =
      defaultMessage ?? 'Failed to process data from server. Please try again.';
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
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
    children: [
      Container(
          margin: const EdgeInsets.only(bottom: 16),
          width: 48,
          decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(48)),
          height: 48,
          child: const Icon(
            Icons.error_outline_rounded,
            color: Colors.red,
            size: 32,
          )),
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Text(
          message,
          textAlign: TextAlign.center,
        ),
      ),
      onRetry != null
          ? TextButton(onPressed: onRetry, child: const Text('Retry')) // Retry
          : const SizedBox.shrink()
    ],
  );
}
