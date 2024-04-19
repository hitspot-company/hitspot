import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/repositories/repo/authentication/hs_authentication.dart';

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
            .registerWithEmailAndPassword(event.email, event.password);
        emit(HSAuthenticationSuccessState(userCredential));
      } on FirebaseAuthException catch (fa) {
        emit(HSAuthenticationFailureState(fa.message ?? "Unknown"));
      } catch (e) {
        emit(HSAuthenticationFailureState(e.toString()));
      }
      emit(const HSAuthenticationLoadingState(false));
    });
    on<HSSignOutEvent>((event, emit) {
      emit(const HSAuthenticationLoadingState(true));
      try {
        _hsAuthRepository.signOutUser();
      } catch (e) {
        print("Could not sign out: $e");
      }
      emit(const HSAuthenticationLoadingState(false));
    });
  }
}
