import 'package:dio/dio.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../utils/data_state.dart';
import '../../../utils/load_status.dart';
import '../../features.dart';

class ProfileCubit extends HydratedCubit<DataState<User>> {
  ProfileCubit(this._repository) : super(const DataState<User>()) {
    // Anda bisa memanggil getProfile di sini jika ingin mengambil data terbaru saat cubit dibuat
  }
  final AuthRepository _repository;

  Future<void> getProfile() async {
    emit(state.copyWith(status: LoadStatus.loading));
    try {
      Map<String, dynamic> response = await _repository.getProfile();
      User? profile = User.fromJson(response);
      setProfile(profile);
    } on DioException catch (e) {
      emit(state.copyWith(status: LoadStatus.failure, error: e));
    }
  }

  Future<void> setProfile(User profile) async {
    // Tidak perlu try-catch di sini karena tidak ada operasi async yang melempar DioException
    emit(state.copyWith(
      status: LoadStatus.success,
      item: profile,
      error: null,
    ));
  }

  @override
  DataState<User>? fromJson(Map<String, dynamic> json) {
    // Menggunakan DataState.fromJson yang sudah kita siapkan
    return DataState.fromJson(json, (jsonUser) => User.fromJson(jsonUser));
  }

  @override
  Map<String, dynamic>? toJson(DataState<User> state) {
    // Menggunakan state.toJson yang sudah kita siapkan
    return state.toJson((user) => user?.toJson());
  }

  void deleteDataProfile() {
    emit(state.copyWith(status: LoadStatus.initial, item: User()));
  }
}
