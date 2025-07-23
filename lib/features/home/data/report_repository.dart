import 'package:dio/dio.dart';
import 'package:sispadu/features/features.dart';

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

  Future<List<Comment>> fetchComments(String reportId, {int page = 1}) async {
    final res = await _dio
        .get('/reports/$reportId/comments', queryParameters: {'page': page});
    return (res.data['data'] as List).map((e) => Comment.fromJson(e)).toList();
  }

  Future<Comment> addComment(String reportId, String content) async {
    final res = await _dio
        .post('/reports/$reportId/comments', data: {'content': content});
    return Comment.fromJson(res.data);
  }

  Future<Comment> editComment(
      String reportId, int commentId, String content) async {
    final res = await _dio.put('/reports/$reportId/comments/$commentId',
        data: {'content': content});
    return Comment.fromJson(res.data);
  }

  Future<void> deleteComment(String reportId, int commentId) async {
    await _dio.delete('/reports/$reportId/comments/$commentId');
  }
}
