import 'package:dio/dio.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../data/auth_repositry.dart';
import 'auth_state.dart';

class AuthCubit extends HydratedCubit<AuthState> {
  final AuthRepository _authRepository;
  AuthCubit(this._authRepository) : super(const AuthState());

  Future<void> checkToken() async {
    _checkTokenFunc(AuthStatus.loading);
  }

  Future<void> _checkTokenFunc(AuthStatus emitStatus) async {
    emit(state.copyWith(status: emitStatus));
    if (state.token.isEmpty) {
      setUnauthenticated();
    }
    try {
      await _authRepository.checkToken();
      emit(state.copyWith(status: AuthStatus.authenticated));
    } on DioException catch (e) {
      int? statusCode = e.response?.statusCode;
      if (statusCode == 401) {
        setUnauthenticated();
        return;
      }
      emit(state.copyWith(status: AuthStatus.failure, error: e));
    }
  }

  void setUnauthenticated() {
    emit(state.copyWith(
        status: AuthStatus.unauthenticated, token: '', isLogin: false));
  }

  void setAuthenticated(String token) {
    emit(state.copyWith(
        status: AuthStatus.authenticated, token: token, isLogin: true));
  }

  void setLocked(DioException e) {
    emit(state.copyWith(status: AuthStatus.locked, error: e));
  }

  @override
  AuthState? fromJson(Map<String, dynamic> json) => AuthState(
        token: json['token'] as String,
      );

  @override
  Map<String, dynamic>? toJson(AuthState state) => {
        'token': state.token,
      };
}
