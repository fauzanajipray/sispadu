import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

import 'load_status.dart';

class DataListState<T> extends Equatable {
  const DataListState({
    this.status = LoadStatus.initial,
    this.itemList = const [],
    this.page = 1,
    this.error,
    this.nextPageKey,
    this.search,
    this.filters,
  });

  final LoadStatus status;
  final List<T> itemList;
  final int page;
  final DioException? error;
  final int? nextPageKey;
  final String? search;
  final Map<String, String>? filters;

  DataListState<T> copyWith({
    LoadStatus? status,
    List<T>? itemList,
    DioException? error,
    int? nextPageKey,
    String? search,
    Map<String, String>? filters,
  }) {
    return DataListState(
      status: status ?? this.status,
      itemList: itemList ?? this.itemList,
      error: error ?? this.error,
      nextPageKey: nextPageKey ?? this.nextPageKey,
      search: search ?? this.search,
      filters: filters ?? this.filters,
    );
  }

  @override
  List<Object?> get props => [
        status,
        itemList,
        error,
        nextPageKey,
        search,
        filters,
      ];
}
