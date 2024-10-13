part of 'hs_magic_link_cubit.dart';

enum HSMagicLinkStatus { idle, verifying, error }

enum HSMagicLinkError { none, emptyOTP, invalidOTP }

final class HSMagicLinkState extends Equatable {
  const HSMagicLinkState(
      {this.otp = "",
      this.status = HSMagicLinkStatus.idle,
      this.error = HSMagicLinkError.none});

  final String otp;
  final HSMagicLinkStatus status;
  final HSMagicLinkError error;

  @override
  List<Object> get props => [otp, status, error];

  HSMagicLinkState copyWith({
    String? otp,
    HSMagicLinkStatus? status,
    HSMagicLinkError? error,
  }) {
    return HSMagicLinkState(
      otp: otp ?? this.otp,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }
}
