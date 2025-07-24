import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sispadu/features/features.dart';
import 'package:sispadu/utils/utils.dart';

class ReportCreateCubit extends Cubit<DataState<void>> {
  ReportCreateCubit(this._repository) : super(const DataState());
  final ReportRepository _repository;

  Future<void> createReport({
    required String title,
    required String content,
    String? postionId,
    required List<String> imageUrls,
  }) async {
    emit(state.copyWith(status: LoadStatus.loading));
    try {
      if (kDebugMode) {
        print('----------- Create Report ------------');
      }

      List<int> imageIds = imageUrls.map((url) {
        final filename =
            url.split('/').last; // hasilnya: "6_1753341008_185912.jpg"
        final idPart = filename.split('_').first; // hasilnya: "6"
        return int.tryParse(idPart) ?? 0;
      }).toList();

      // Prepare the request payload
      final payload = {
        "title": title,
        "content": content,
        "temp_position_id": postionId,
        "images": imageIds.map((e) => {"image_id": e}).toList(),
      };

      // Send the request
      await _repository.postReport(payload);

      emit(state.copyWith(status: LoadStatus.success));
    } on DioException catch (e) {
      emit(state.copyWith(status: LoadStatus.failure, error: e));
    }
  }

  Future<void> updateReport({
    required String id,
    required String title,
    required String content,
    String? postionId,
    required List<String> imageUrls,
  }) async {
    emit(state.copyWith(status: LoadStatus.loading));
    try {
      // Extract image IDs from URLs
      // https://sispadu.web.id/storage/images/reports/6_1753341008_185912.jpg

      List<int> imageIds = imageUrls.map((url) {
        final filename =
            url.split('/').last; // hasilnya: "6_1753341008_185912.jpg"
        final idPart = filename.split('_').first; // hasilnya: "6"
        return int.tryParse(idPart) ?? 0;
      }).toList();

      // Prepare the request payload
      final payload = {
        "title": title,
        "content": content,
        "temp_position_id": postionId,
        "images": imageIds.map((e) => {"image_id": e}).toList(),
      };

      // Send the request
      await _repository.updateReport(id, payload);

      emit(state.copyWith(status: LoadStatus.success));
    } on DioException catch (e) {
      emit(state.copyWith(status: LoadStatus.failure, error: e));
    }
  }
}
