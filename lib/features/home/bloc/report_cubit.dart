import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sispadu/features/features.dart';
import 'package:sispadu/utils/utils.dart';

class ReportCubit extends Cubit<DataState<Report>> {
  ReportCubit(this._repository) : super(const DataState<Report>());

  final ReportRepository _repository;

  /// Fetches the details of a specific competitor review by ID.
  ///
  /// Parameters:
  /// - [id] (String): The ID of the competitor review to fetch.
  Future<void> getReportDetail(String id, {bool isAuth = false}) async {
    emit(state.copyWith(status: LoadStatus.loading));
    try {
      // Fetch review details from the repository
      Map<String, dynamic> response;
      if (isAuth) {
        response = await _repository.getReportDetail(id);
      } else {
        response = await _repository.getReportPublicDetail(id);
      }

      // Parse the response into a Report model
      Report review = Report.fromJson(response);

      // Emit the success state with the fetched review
      emit(state.copyWith(
        status: LoadStatus.success,
        item: review,
        error: null,
      ));
    } on DioException catch (e) {
      // Emit the failure state with the error
      emit(state.copyWith(status: LoadStatus.failure, error: e));
    }
  }
}
