part of 'hs_authentication_bloc.dart';

sealed class HSAuthenticationEvent extends Equatable {
  const HSAuthenticationEvent();

  @override
  List<Object> get props => [];
}

final class HSAuthenticationLogoutEvent extends HSAuthenticationEvent {
  const HSAuthenticationLogoutEvent();
}

final class HSAuthenticationMagicLinkCancelled extends HSAuthenticationEvent {
  const HSAuthenticationMagicLinkCancelled();
}

final class HSAuthenticationUserChangedEvent extends HSAuthenticationEvent {
  const HSAuthenticationUserChangedEvent({required this.user});

  final HSUser? user;
}

final class HSAuthenticationMagicLinkSentEvent extends HSAuthenticationEvent {
  const HSAuthenticationMagicLinkSentEvent(this.email);

  final String email;
}
