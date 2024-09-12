part of 'hs_settings_bloc.dart';

enum HSLaunchSettingsType { gallery, location, notifications }

enum HSThemeMode { light, dark, auto }

final class HsSettingsState extends Equatable {
  const HsSettingsState();

  @override
  List<Object> get props => [];
}

final class HsSettingsStateReady extends HsSettingsState {
  const HsSettingsStateReady();

  @override
  List<Object> get props => [];
}

final class HsSettingsStateInitial extends HsSettingsState {
  const HsSettingsStateInitial();
}
