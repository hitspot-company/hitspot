part of 'hs_settings_bloc.dart';

sealed class HsSettingsEvent extends Equatable {
  const HsSettingsEvent();

  @override
  List<Object> get props => [];
}

final class HsSettingsLoadEvent extends HsSettingsEvent {
  const HsSettingsLoadEvent();

  @override
  List<Object> get props => [];
}

final class HSSettingsSwitchThemeModeEvent extends HsSettingsEvent {
  const HSSettingsSwitchThemeModeEvent();

  @override
  List<Object> get props => [];
}
