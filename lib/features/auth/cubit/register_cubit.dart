import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sispadu/features/features.dart';

class RegisterCubit extends Cubit<LoginState> {
  RegisterCubit(this._authRepository) : super(const LoginState());
  final AuthRepository _authRepository;

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    emit(state.copyWith(status: LoginStatus.loading));
    try {
      Map<String, dynamic> response = await _authRepository.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      emit(state.copyWith(
          status: LoginStatus.success, data: response, error: null));
    } on DioException catch (e) {
      emit(state.copyWith(status: LoginStatus.failure, error: e));
    }
  }
}
