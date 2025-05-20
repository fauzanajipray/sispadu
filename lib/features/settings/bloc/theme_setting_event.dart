abstract class ThemeSettingEvent {}

class UpdateThemeSystem extends ThemeSettingEvent {
  bool isSystem;
  UpdateThemeSystem(this.isSystem);
}

class UpdateThemeManual extends ThemeSettingEvent {
  bool isLightMode;
  UpdateThemeManual(this.isLightMode);
}
