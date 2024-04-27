part of 'hs_authentication_bloc.dart';

sealed class HSAuthenticationEvent {
  const HSAuthenticationEvent();
}

final class HSAppLogoutRequested extends HSAuthenticationEvent {
  const HSAppLogoutRequested();
}

final class _HSAppUserChanged extends HSAuthenticationEvent {
  final HSUser? user;

  const _HSAppUserChanged(this.user);
}
