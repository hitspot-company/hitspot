import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/repositories/authentication/hs_authentication.dart';

part 'hs_authentication_event.dart';
part 'hs_authentication_state.dart';

class HSAuthenticationBloc
    extends Bloc<HSAuthenticationEvent, HSAuthenticationState> {
  final HSAuthenticationRepository _hsAuthRepository;
  HSAuthenticationBloc(this._hsAuthRepository)
      : super(HSAuthenticationInitialState()) {
    on<HSAuthenticationEvent>((event, emit) {});
    on<HSSignUpEvent>((event, emit) async {
      emit(const HSAuthenticationLoadingState(true));
      try {
        final UserCredential userCredential = await _hsAuthRepository
            .signUpWithEmailAndPassword(event.email, event.password);
        emit(HSAuthenticationSuccessState(userCredential));
      } on FirebaseAuthException catch (fa) {
        emit(HSAuthenticationFailureState(fa.message ?? "Unknown"));
      } catch (e) {
        emit(HSAuthenticationFailureState(e.toString()));
      }
      emit(const HSAuthenticationLoadingState(false));
    });
    on<HSSignInEvent>((event, emit) async {
      emit(const HSAuthenticationLoadingState(true));
      try {
        final UserCredential userCredential = await _hsAuthRepository
            .signInWithEmailAndPassword(event.email, event.password);
        emit(HSAuthenticationSuccessState(userCredential));
      } on FirebaseAuthException catch (fa) {
        emit(HSAuthenticationFailureState(fa.message ?? "Unknown"));
      } catch (e) {
        emit(HSAuthenticationFailureState(e.toString()));
      }
      emit(const HSAuthenticationLoadingState(false));
    });
    on<HSSignOutEvent>((event, emit) async {
      emit(const HSAuthenticationLoadingState(true));
      try {
        await _hsAuthRepository
            .signOutUser(); // BUG: The state does not change on the register page
      } catch (e) {
        print("Could not sign out: $e");
      }
      emit(const HSAuthenticationLoadingState(false));
    });
  }
}
