part of 'hs_authentication_bloc.dart';

sealed class HSAuthenticationEvent {
  const HSAuthenticationEvent();
}

final class HSAppLogoutRequested extends HSAuthenticationEvent {
  const HSAppLogoutRequested();
}

final class HSAppUserChanged extends HSAuthenticationEvent {
  final HSUser? user;

  const HSAppUserChanged(this.user);
}

final class HSAppUserReload extends HSAuthenticationEvent {
  const HSAppUserReload();
}
