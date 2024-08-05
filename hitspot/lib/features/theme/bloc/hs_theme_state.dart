part of 'hs_theme_bloc.dart';

sealed class HSThemeState extends Equatable {
  const HSThemeState(this.theme, {this.mapStyle});

  final ThemeData theme;
  final String? mapStyle;

  @override
  List<Object?> get props => [theme, mapStyle];
}

final class HSThemeStateDark extends HSThemeState {
  HSThemeStateDark({super.mapStyle}) : super(HSTheme.instance.darkTheme);
}

final class HSThemeStateLight extends HSThemeState {
  HSThemeStateLight({super.mapStyle}) : super(HSTheme.instance.lightTheme);
}
