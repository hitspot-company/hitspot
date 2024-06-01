import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/main.dart';
import 'package:hitspot/utils/forms/hs_email.dart';
import 'package:hitspot/utils/forms/hs_password.dart';
import 'package:hitspot/utils/navigation/hs_navigation.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';

part 'hs_login_state.dart';

class HSLoginCubit extends Cubit<HSLoginState> {
  HSLoginCubit() : super(const HSLoginState());

  final HSAuthenticationRepository _authenticationRepository =
      HSAuthenticationRepository(supabase);

  void updateEmail(String value) =>
      emit(state.copyWith(email: HSEmail.dirty(value)));

  void signIn() async {
    emit(state.copyWith(loginStatus: HSLoginStatus.loading));
    try {
      HSDebugLogger.logInfo("Sign in");
      await _authenticationRepository.logInWithEmailAndPassword(
          email: "jnenczak@hitspot.app", password: "Password123");
    } on LogInWithEmailAndPasswordFailure catch (_) {
      HSDebugLogger.logError(_.message);
    } catch (_) {
      HSDebugLogger.logError(_.toString());
    }
  }
}
