part of 'hs_authentication_bloc.dart';

enum HSAuthenticationStatus {
  unknown,
  unauthenitcated,
  emailNotVerified,
  profileIncomplete,
  magicLinkSent,
  authenticated
}

sealed class HSAuthenticationState extends Equatable {
  const HSAuthenticationState({
    this.authenticationStatus = HSAuthenticationStatus.unknown,
  });

  final HSAuthenticationStatus authenticationStatus;

  @override
  List<Object> get props => [authenticationStatus];
}

final class HSAuthenticationInitial extends HSAuthenticationState {
  const HSAuthenticationInitial({super.authenticationStatus});
}

final class HSAuthenticationAuthenticatedState extends HSAuthenticationState {
  const HSAuthenticationAuthenticatedState({
    required this.currentUser,
    super.authenticationStatus = HSAuthenticationStatus.authenticated,
  });

  final HSUser currentUser;

  @override
  List<Object> get props => [super.authenticationStatus, currentUser];
}

final class HSAuthenticationMagicLinkSentState extends HSAuthenticationState {
  const HSAuthenticationMagicLinkSentState(
    this.email, {
    super.authenticationStatus = HSAuthenticationStatus.magicLinkSent,
  });

  final String email;

  @override
  List<Object> get props => [super.authenticationStatus, email];
}

final class HSAuthenticationUnauthenticatedState extends HSAuthenticationState {
  const HSAuthenticationUnauthenticatedState({
    super.authenticationStatus = HSAuthenticationStatus.unauthenitcated,
  });
}

final class HSAuthenticationEmailNotVerifiedState
    extends HSAuthenticationState {
  const HSAuthenticationEmailNotVerifiedState({
    required this.currentUser,
    super.authenticationStatus = HSAuthenticationStatus.emailNotVerified,
  });

  final HSUser currentUser;

  @override
  List<Object> get props => [super.authenticationStatus, currentUser];
}

final class HSAuthenticationProfileIncompleteState
    extends HSAuthenticationState {
  const HSAuthenticationProfileIncompleteState({
    required this.currentUser,
    super.authenticationStatus = HSAuthenticationStatus.profileIncomplete,
  });

  final HSUser currentUser;

  @override
  List<Object> get props => [super.authenticationStatus, currentUser];
}
