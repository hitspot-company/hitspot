part of 'hs_authentication_bloc.dart';

sealed class HSAuthenticationState extends Equatable {
  const HSAuthenticationState();

  @override
  List<Object> get props => [];
}

final class HSAuthenticationInitialState extends HSAuthenticationState {}

final class HSAuthenticationLoadingState extends HSAuthenticationState {
  final bool isLoading;

  const HSAuthenticationLoadingState(this.isLoading);
}

final class HSAuthenticationSuccessState extends HSAuthenticationState {
  final UserCredential user;

  const HSAuthenticationSuccessState(this.user);

  @override
  List<Object> get props => [user];
}

final class HSAuthenticationFailureState extends HSAuthenticationState {
  final String errorMessage;

  const HSAuthenticationFailureState(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
