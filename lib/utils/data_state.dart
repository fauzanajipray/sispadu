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

  factory DataState.fromJson(
      Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonT) {
    return DataState(
      status: LoadStatus.values.byName(json['status'] ?? 'initial'),
      item: json['item'] != null ? fromJsonT(json['item']) : null,
      data: json['data'],
      error: null, // Error tidak dipulihkan dari storage
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic>? Function(T?) toJsonT) {
    return {
      'status': status.name,
      'item': toJsonT(item),
      'data': data,
      // Error tidak disimpan
    };
  }

  @override
  List<Object?> get props => [
        status,
        data,
        item,
        error,
      ];
}
