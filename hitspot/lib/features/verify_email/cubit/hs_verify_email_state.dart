part of 'hs_verify_email_cubit.dart';

enum HSEmailVerificationState {
  initial,
  initialSent,
  sending,
  failedToResend,
  resent,
  verifying,
  verified,
  unverified
}

final class HSVerifyEmailState extends Equatable {
  const HSVerifyEmailState({
    this.emailVerificationState = HSEmailVerificationState.initial,
  });

  final HSEmailVerificationState emailVerificationState;

  @override
  List<Object> get props => [emailVerificationState];

  HSVerifyEmailState copyWith({
    HSEmailVerificationState? emailVerificationState,
  }) =>
      HSVerifyEmailState(
          emailVerificationState:
              emailVerificationState ?? this.emailVerificationState);
}
