part of 'hs_app_bloc.dart';

enum HSAppStatus {
  authenticated,
  profileNotCompleted,
  unauthenticated,
}

final class HSAppState extends Equatable {
  final HSAppStatus status;
  final HSUser user;

  const HSAppState._({
    required this.status,
    this.user = const HSUser(),
  });

  const HSAppState.authenticated(HSUser user)
      : this._(status: HSAppStatus.authenticated, user: user);

  const HSAppState.profileNotCompleted(HSUser user)
      : this._(status: HSAppStatus.profileNotCompleted, user: user);

  const HSAppState.unauthenticated()
      : this._(status: HSAppStatus.unauthenticated);

  @override
  List<Object> get props => [status, user];
}
