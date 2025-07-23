import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sispadu/features/features.dart';
import 'package:sispadu/utils/utils.dart';

class ReportListBloc extends Bloc<DataListingEvent, DataListState<Report>> {
  ReportListBloc(this._repository) : super(const DataListState()) {
    on<DataListingEvent>((event, emit) async {
      if (event is FetchEvent) {
        DataListState<Report> stateData =
            await fetchListing(event.pageKey, state.search);
        emit(stateData);
      } else if (event is ResetSearchTermEvent) {
        emit(_resetSearching(event.search));
      } else if (event is ResetPage) {
        emit(_resetPage());
      }
    });
  }

  static const _pageSize = 20;
  final ReportRepository _repository;
  Future<DataListState<Report>> fetchListing(int pageKey,
      [String? search]) async {
    final lastListingState = state.copyWith(status: LoadStatus.loading);
    try {
      final response = await _repository.getReportList(pageKey, search, '');
      var data = response['data'] as List;
      List<Report> newItems = data.map((x) => Report.fromJson(x)).toList();
      final isLastPage = newItems.length < _pageSize;
      final nextPageKey = isLastPage ? null : pageKey + 1;

      List<Report> itemListBefore;
      if (pageKey == 1) {
        itemListBefore = [];
      } else {
        itemListBefore = lastListingState.itemList;
      }
      return DataListState(
        status: LoadStatus.success,
        error: null,
        nextPageKey: nextPageKey,
        itemList: [
          ...itemListBefore,
          ...newItems,
        ],
      );
    } on DioException catch (e) {
      return DataListState(
        status: LoadStatus.failure,
        error: e,
        nextPageKey: lastListingState.nextPageKey,
        itemList: lastListingState.itemList,
      );
    }
  }

  DataListState<Report> _resetSearching(String? search) {
    return state.copyWith(
      status: LoadStatus.reset,
      search: search,
      itemList: [],
    );
  }

  DataListState<Report> _resetPage() {
    return state.copyWith(status: LoadStatus.reset);
  }
}
