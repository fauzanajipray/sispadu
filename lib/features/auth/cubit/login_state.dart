import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

enum LoginStatus { initial, loading, success, failure }

class LoginState extends Equatable {
  const LoginState(
      {this.status = LoginStatus.initial, this.data = const {}, this.error});
  final LoginStatus status;
  final Map<String, dynamic> data;
  final DioException? error;

  LoginState copyWith(
      {LoginStatus? status, Map<String, dynamic>? data, DioException? error}) {
    return LoginState(
        status: status ?? this.status,
        data: data ?? this.data,
        error: error ?? this.error);
  }

  @override
  List<Object?> get props => [status, data];
}
