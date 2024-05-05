part of 'hs_authentication_bloc.dart';

enum HSAppStatus {
  loading,
  authenticated,
  emailNotVerified,
  profileNotCompleted,
  unauthenticated,
}

final class HSAuthenticationState extends Equatable {
  final HSAppStatus status;
  final HSUser user;

  const HSAuthenticationState._({
    required this.status,
    this.user = const HSUser(),
  });

  const HSAuthenticationState.loading() : this._(status: HSAppStatus.loading);

  const HSAuthenticationState.authenticated(HSUser user)
      : this._(status: HSAppStatus.authenticated, user: user);

  const HSAuthenticationState.emailNotVerified()
      : this._(status: HSAppStatus.emailNotVerified);

  const HSAuthenticationState.profileNotCompleted(HSUser user)
      : this._(status: HSAppStatus.profileNotCompleted, user: user);

  const HSAuthenticationState.unauthenticated()
      : this._(status: HSAppStatus.unauthenticated);

  @override
  List<Object> get props => [status, user];
}
