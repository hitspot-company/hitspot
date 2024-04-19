import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/constants/hs_const.dart';
import 'package:hitspot/repositories/repo/theme/hs_theme.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class HSThemeBloc extends Bloc<HSThemeEvent, HSThemeState> {
  final HSThemeRepository _repo;

  HSThemeBloc(this._repo) : super(HSThemeStateDark()) {
    on<HSInitialThemeSetEvent>((event, emit) async {
      final bool hasDarkTheme = await _repo.isDark();
      if (hasDarkTheme) {
        emit(HSThemeStateDark());
      } else {
        emit(HSThemeStateLight());
      }
    });
    on<HSThemeSwitchEvent>((event, emit) {
      final isDark = state.theme == HSConstants.theming.darkTheme;
      emit(isDark ? HSThemeStateLight() : HSThemeStateDark());
      _repo.setTheme(isDark);
    });
  }
}
