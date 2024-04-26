part of 'hs_theme_bloc.dart';

sealed class HSThemeState extends Equatable {
  const HSThemeState(this.theme);

  final ThemeData theme;

  @override
  List<Object> get props => [];
}

final class HSThemeStateDark extends HSThemeState {
  HSThemeStateDark() : super(HSTheme.instance.darkTheme);
}

final class HSThemeStateLight extends HSThemeState {
  HSThemeStateLight() : super(HSTheme.instance.lightTheme);
}
