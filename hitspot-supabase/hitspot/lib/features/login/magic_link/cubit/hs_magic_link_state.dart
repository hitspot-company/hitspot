part of 'hs_magic_link_cubit.dart';

enum HSMagicLinkStatus { idle, verifying, error }

final class HSMagicLinkState extends Equatable {
  const HSMagicLinkState({this.otp = "", this.status = HSMagicLinkStatus.idle});

  final String otp;
  final HSMagicLinkStatus status;

  @override
  List<Object> get props => [otp];

  HSMagicLinkState copyWith({
    String? otp,
  }) {
    return HSMagicLinkState(otp: otp ?? this.otp);
  }
}
