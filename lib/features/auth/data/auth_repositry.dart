import 'package:dio/dio.dart';

import '../../../services/dio_client.dart';

class AuthRepository {
  late final Dio _dio;

  AuthRepository() {
    _dio = DioClient().client;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    Response response =
        await _dio.post('/login', data: {"email": email, "password": password});
    return response.data;
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    Response response = await _dio.post('/register', data: {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation
    });

    return response.data;
  }

  Future<Map<String, dynamic>> checkToken() async {
    Response response = await _dio.get('/check-token');
    return response.data;
  }

  Future<String> loginWeb() async {
    Response response = await _dio.post('/login-web');
    return response.data;
  }

  /// Get Profile
  Future<Map<String, dynamic>> getProfile() async {
    Response response = await _dio.get('/profile');
    return response.data;
  }

  /// Update Profile
  Future<Map<String, dynamic>> updateProfile(String json) async {
    Options options = Options()..contentType = 'application/json';
    Response response =
        await _dio.post('/profile', data: json, options: options);
    return response.data;
  }
}
