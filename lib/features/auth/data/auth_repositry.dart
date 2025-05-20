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

  Future<Map<String, dynamic>> checkToken() async {
    Response response = await _dio.get('/check-token');
    return response.data;
  }

  Future<String> loginWeb() async {
    Response response = await _dio.post('/login-web');
    return response.data;
  }
}
