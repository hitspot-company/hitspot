import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hitspot/main.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'hs_magic_link_state.dart';

class HSMagicLinkCubit extends Cubit<HSMagicLinkState> {
  HSMagicLinkCubit({required this.email}) : super(const HSMagicLinkState());

  final String email;

  void updateOtp(String value) =>
      emit(state.copyWith(otp: value, error: HSMagicLinkError.none));

  Future<void> verifyOtp() async {
    try {
      emit(state.copyWith(status: HSMagicLinkStatus.verifying));
      await supabase.auth
          .verifyOTP(email: email, token: state.otp, type: OtpType.magiclink);
      HSDebugLogger.logSuccess("Successfully verified OTP!");
      emit(state.copyWith(status: HSMagicLinkStatus.idle));
      return;
    } on AuthException catch (e) {
      if (state.otp == "") {
        emit(state.copyWith(
            status: HSMagicLinkStatus.error, error: HSMagicLinkError.emptyOTP));
      } else {
        emit(state.copyWith(
            status: HSMagicLinkStatus.error,
            error: HSMagicLinkError.invalidOTP));
      }
      HSDebugLogger.logError(e.message);
    } catch (_) {
      HSDebugLogger.logError(_.toString());
      emit(state.copyWith(status: HSMagicLinkStatus.error));
    }
  }
}
