import 'package:hydrated_bloc/hydrated_bloc.dart';

import 'auth_state.dart';

class AuthCubit extends HydratedCubit<AuthState> {
  AuthCubit() : super(const AuthState());

  Future<void> checkToken() async {
    emit(state.copyWith(status: AuthStatus.loading));
    if (state.token.isEmpty) {
      setUnauthenticated();
    } else {
      emit(state.copyWith(status: AuthStatus.authenticated));
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

  @override
  AuthState? fromJson(Map<String, dynamic> json) => AuthState(
        token: json['token'] as String,
      );

  @override
  Map<String, dynamic>? toJson(AuthState state) => {
        'token': state.token,
      };
}
