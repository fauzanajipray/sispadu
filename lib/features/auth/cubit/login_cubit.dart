import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/auth_repositry.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._authRepository) : super(const LoginState());
  final AuthRepository _authRepository;

  Future<void> login(String email, String password) async {
    emit(state.copyWith(status: LoginStatus.loading));
    try {
      Map<String, dynamic> response =
          await _authRepository.login(email, password);
      emit(state.copyWith(
          status: LoginStatus.success, data: response, error: null));
    } on DioException catch (e) {
      emit(state.copyWith(status: LoginStatus.failure, error: e));
    }
  }
}
