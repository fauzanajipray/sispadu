import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../constant/app_constant.dart';
import '../features/auth/cubit/auth_cubit.dart';

class DioClient {
  final Dio _dio = Dio();
  AuthCubit? authCubit;
  static final DioClient _dioClient = DioClient._internal();

  factory DioClient({AuthCubit? authCubit}) {
    if (authCubit != null) {
      _dioClient.authCubit = authCubit;
    }
    return _dioClient;
  }

  void init() {
    String token = "";
    if (authCubit != null) {
      token = authCubit!.state.token;

      if (token.isNotEmpty) {
        _dio.interceptors.add(InterceptorsWrapper(
          onRequest: (options, handler) {
            options.headers['Authorization'] = 'Bearer $token';
            return handler.next(options);
          },
          onResponse: (response, handler) {
            return handler.next(response);
          },
          onError: (DioException e, handler) {
            return handler.next(e);
          },
        ));
      }
    }
  }

  DioClient._internal() {
    _dio
      ..options.baseUrl = AppConstant.baseUrl
      ..options.receiveTimeout =
          const Duration(milliseconds: AppConstant.apiReceiveTimeout)
      ..options.sendTimeout =
          const Duration(milliseconds: AppConstant.apiSendTimeout)
      ..options.headers['Accept'] = 'application/json';

    if (kDebugMode) {
      // ✅ **Bypass SSL Verification DI SERVER hub.rectmedia.com**
      (_dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      };
    }
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // print("URL ${options.path}");
        // print("Data ${options.headers}");
        return handler.next(options);
      },
      onResponse: (response, handler) {
        // print("Response ${response.realUri}");
        // print("Response ${response.statusCode}");
        return handler.next(response);
      },
      onError: (e, handler) {
        final authCubit = this.authCubit;
        if (authCubit != null) {
          if (e.type == DioExceptionType.badResponse) {
            int? statusCode = e.response?.statusCode;
            if (kDebugMode) {
              print('Error Status code $statusCode');
              // print error data
              print('Error data : ${e.response}');
            }
            if (statusCode == 401) {
              authCubit.setUnauthenticated();
            } else if (statusCode == 423) {
              authCubit.setLocked(e);
            }
          } else {
            // print('Error occured');
            if (kDebugMode) {
              print(e.message);
              print(e);
            }
          }
        }
        return handler.next(e);
      },
    ));
    if (kDebugMode) {
      _dio.interceptors.add(PrettyDioLogger(
        requestHeader: false,
        requestBody: false,
        responseBody: true,
        responseHeader: false,
        error: false,
        compact: false,
        maxWidth: 90,
      ));
    }
  }

  Dio get client => _dio;
}
