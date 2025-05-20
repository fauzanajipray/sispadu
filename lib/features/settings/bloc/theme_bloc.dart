import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import 'theme_setting_event.dart';

class ThemeBloc extends HydratedBloc<ThemeSettingEvent, ThemeState> {
  ThemeBloc() : super(const ThemeState()) {
    on<ThemeSettingEvent>((event, emit) async {
      if (event is UpdateThemeSystem) {
        emit(state.copyWith(isThemeSystem: event.isSystem));
      } else if (event is UpdateThemeManual) {
        emit(state.copyWith(isThemeLight: event.isLightMode));
      }
    }, transformer: restartable());
  }

  @override
  ThemeState fromJson(Map<String, dynamic> json) {
    return ThemeState.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(ThemeState state) {
    return state.toJson();
  }
}

class ThemeState extends Equatable {
  final bool isThemeSystem;
  final bool isThemeLight;

  const ThemeState({
    this.isThemeSystem = true,
    this.isThemeLight = false,
  });

  ThemeState copyWith({
    bool? isThemeSystem,
    bool? isThemeLight,
  }) {
    return ThemeState(
      isThemeSystem:
          (isThemeSystem == null) ? this.isThemeSystem : isThemeSystem,
      isThemeLight: (isThemeLight == null) ? this.isThemeLight : isThemeLight,
    );
  }

  @override
  List<Object?> get props => [
        isThemeLight,
        isThemeSystem,
      ];

  factory ThemeState.fromJson(Map<String, dynamic> json) {
    return ThemeState(
      isThemeSystem: json['is_theme_system'] as bool,
      isThemeLight: json['is_theme_light'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_theme_system': isThemeSystem,
      'is_theme_light': isThemeLight,
    };
  }
}
