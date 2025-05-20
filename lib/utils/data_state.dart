import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

import 'load_status.dart';

class DataState<T> extends Equatable {
  const DataState({
    this.status = LoadStatus.initial,
    this.data = const {},
    this.item,
    this.error,
  });

  final LoadStatus status;
  final Map<String, dynamic> data;
  final T? item;
  final DioException? error;

  DataState<T> copyWith({
    LoadStatus? status,
    Map<String, dynamic>? data,
    T? item,
    DioException? error,
  }) {
    return DataState<T>(
      status: status ?? this.status,
      data: data ?? this.data,
      item: item ?? this.item,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        status,
        data,
        item,
        error,
      ];
}
