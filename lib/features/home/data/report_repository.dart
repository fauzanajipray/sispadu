import 'package:dio/dio.dart';

import '../../../services/dio_client.dart';

class ReportRepository {
  late final Dio _dio;

  ReportRepository() {
    _dio = DioClient().client;
  }

  Future<Map<String, dynamic>> getReportList(
      int page, String? search, String? status) async {
    final queryParameters = {
      'page': page.toString(),
      'search': search ?? '',
      'status': '',
    };
    Response response =
        await _dio.get('/report', queryParameters: queryParameters);
    return response.data;
  }

  Future<Map<String, dynamic>> getReportDetail(String id) async {
    Response response = await _dio.get('/report/$id');
    return response.data;
  }

  Future<Map<String, dynamic>> getReportPublicDetail(String id) async {
    Response response = await _dio.get('/p/report/$id');
    return response.data;
  }
}
