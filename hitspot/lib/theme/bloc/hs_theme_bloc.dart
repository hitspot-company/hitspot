import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/constants/hs_theme.dart';
import 'package:hs_theme_repository/hs_form_inputs.dart';

part 'hs_theme_event.dart';
part 'hs_theme_state.dart';

class HSThemeBloc extends Bloc<HSThemeEvent, HSThemeState> {
  final HSThemeRepository _themeRepository;

  HSThemeBloc(this._themeRepository) : super(HSThemeStateDark()) {
    on<HSInitialThemeSetEvent>((event, emit) async {
      final bool hasDarkTheme = await _themeRepository.isDark();
      if (hasDarkTheme) {
        emit(HSThemeStateDark());
      } else {
        emit(HSThemeStateLight());
      }
    });
    on<HSThemeSwitchEvent>((event, emit) {
      final isDark = state.theme == HSTheme.instance.darkTheme;
      emit(isDark ? HSThemeStateLight() : HSThemeStateDark());
      _themeRepository.setTheme(isDark);
    });
  }
}
