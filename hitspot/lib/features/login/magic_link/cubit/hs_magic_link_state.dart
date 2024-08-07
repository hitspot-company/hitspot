part of 'hs_magic_link_cubit.dart';

enum HSMagicLinkStatus { idle, verifying, error }

final class HSMagicLinkState extends Equatable {
  const HSMagicLinkState(
      {this.otp = "",
      this.status = HSMagicLinkStatus.idle,
      this.errorMessage = ""});

  final String otp;
  final HSMagicLinkStatus status;
  final String errorMessage;

  @override
  List<Object> get props => [otp, status, errorMessage];

  HSMagicLinkState copyWith({
    String? otp,
    HSMagicLinkStatus? status,
    String? errorMessage,
  }) {
    return HSMagicLinkState(
      otp: otp ?? this.otp,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
