part of 'hs_authentication_bloc.dart';

sealed class HSAuthenticationEvent extends Equatable {
  const HSAuthenticationEvent();

  @override
  List<Object> get props => [];
}

class HSSignUpEvent extends HSAuthenticationEvent {
  final String email;
  final String password;

  const HSSignUpEvent({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class HSSignOutEvent extends HSAuthenticationEvent {}
