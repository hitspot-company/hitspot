part of 'theme_bloc.dart';

sealed class HSThemeState extends Equatable {
  const HSThemeState(this.theme);

  final ThemeData theme;

  @override
  List<Object> get props => [];
}

final class HSThemeStateDark extends HSThemeState {
  HSThemeStateDark() : super(HSConstants.theming.darkTheme);
}

final class HSThemeStateLight extends HSThemeState {
  HSThemeStateLight() : super(HSConstants.theming.lightTheme);
}
