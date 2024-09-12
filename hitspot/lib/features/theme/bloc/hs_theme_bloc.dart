import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';
import 'package:hs_theme_repository/hs_theme.dart';

part 'hs_theme_event.dart';
part 'hs_theme_state.dart';

class HSThemeBloc extends Bloc<HSThemeEvent, HSThemeState> {
  final HSThemeRepository _themeRepository;
  final HSTheme _theme;

  HSThemeBloc(this._themeRepository, this._theme) : super(HSThemeStateDark()) {
    on<HSInitialThemeSetEvent>((event, emit) async {
      await _theme.initialize(); // Ensure theme is initialized
      final bool hasDarkTheme = await _themeRepository.isDark();
      if (hasDarkTheme) {
        emit(HSThemeStateDark(mapStyle: _theme.mapStyleDark));
      } else {
        emit(HSThemeStateLight(mapStyle: _theme.mapStyleLight));
      }
    });

    on<HSThemeSwitchEvent>((event, emit) async {
      if (!_theme.isInitialized) {
        await _theme.initialize();
      }
      final isDark = state.theme == HSTheme.instance.darkTheme;
      emit(isDark
          ? HSThemeStateLight(mapStyle: _theme.mapStyleLight)
          : HSThemeStateDark(mapStyle: _theme.mapStyleDark));
      _themeRepository.setTheme(isDark);
    });
  }
}
