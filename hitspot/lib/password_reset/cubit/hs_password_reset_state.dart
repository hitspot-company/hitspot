part of 'hs_password_reset_cubit.dart';

enum HSPasswordResetPageState { initial, sending, sent, reset }

final class HSPasswordResetState extends Equatable {
  const HSPasswordResetState({
    this.pageState = HSPasswordResetPageState.initial,
    this.email = const Email.pure(),
    this.errorMessage,
  });

  final Email email;
  final HSPasswordResetPageState pageState;
  final String? errorMessage;

  @override
  List<Object?> get props => [pageState, email, errorMessage];

  HSPasswordResetState copyWith(
      {HSPasswordResetPageState? pageState,
      Email? email,
      String? errorMessage}) {
    return HSPasswordResetState(
      pageState: pageState ?? this.pageState,
      email: email ?? this.email,
      errorMessage: errorMessage,
    );
  }
}
