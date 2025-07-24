import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sispadu/features/home/data/report.dart';
import 'package:sispadu/features/home/data/report_repository.dart';
import 'package:sispadu/utils/utils.dart';

class ReportUploadImageCubit extends Cubit<DataState<ReportImage>> {
  ReportUploadImageCubit(this._repository) : super(const DataState());
  final ReportRepository _repository;

  Future<void> uploadImage(File image) async {
    emit(state.copyWith(status: LoadStatus.loading));
    try {
      Map<String, dynamic> response =
          await _repository.uploadSingleImage(image);
      ReportImage data = ReportImage.fromJson(response);
      emit(state.copyWith(
        status: LoadStatus.success,
        item: data,
        error: null,
      ));
    } on DioException catch (e) {
      emit(state.copyWith(status: LoadStatus.failure, error: e));
    }
  }
}
