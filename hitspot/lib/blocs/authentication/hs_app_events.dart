part of 'hs_app_bloc.dart';

sealed class HSAppEvent {
  const HSAppEvent();
}

final class HSAppLogoutRequested extends HSAppEvent {
  const HSAppLogoutRequested();
}

final class _HSAppUserChanged extends HSAppEvent {
  final HSUser? user;

  const _HSAppUserChanged(this.user);
}
