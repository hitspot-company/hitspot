part of 'theme_bloc.dart';

sealed class HSThemeEvent extends Equatable {
  const HSThemeEvent();

  @override
  List<Object> get props => [];
}

class HSInitialThemeSetEvent extends HSThemeEvent {}

class HSThemeSwitchEvent extends HSThemeEvent {}
