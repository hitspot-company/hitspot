import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';

part 'hs_authentication_event.dart';
part 'hs_authentication_state.dart';

class HSAuthenticationBloc
    extends Bloc<HSAuthenticationEvent, HSAuthenticationState> {
  HSAuthenticationBloc() : super(const HSAuthenticationInitial()) {
    on<HSAuthenticationUserChangedEvent>((event, emit) async {
      try {
        final HSUser? user = event.user;
        HSDebugLogger.logInfo("initial user: $user");
        // 1. The user is not authenticated
        if (user == null) {
          emit(const HSAuthenticationUnauthenticatedState());
          return;
        }
        // 2. The user is signed in
        final HSUser fetchedUser =
            await app.databaseRepository.userRead(user: user);
        if (fetchedUser.isProfileCompleted == true) {
          emit(HSAuthenticationAuthenticatedState(currentUser: fetchedUser));
        } else {
          emit(
              HSAuthenticationProfileIncompleteState(currentUser: fetchedUser));
          print("EMITTED");
        }
      } on HSReadUserFailure catch (_) {
        HSDebugLogger.logError("Failed to read user: $_");
        app.signOut();
      } catch (_) {
        HSDebugLogger.logError(_.toString());
      }
    });
    on<HSAuthenticationMagicLinkSentEvent>(
      (event, emit) => emit(HSAuthenticationMagicLinkSentState(event.email)),
    );
    on<HSAuthenticationLogoutEvent>((event, emit) async {
      try {
        await app.authenticationRepository.signOut();
      } catch (_) {
        HSDebugLogger.logError(_.toString());
      }
    });
  }

  void initializeStreamSubscription() {
    _userSubscription = app.authenticationRepository.user
        .listen((user) => userChangedEvent(user: user));
  }

  late final StreamSubscription<HSUser?> _userSubscription;
  StreamSubscription<HSUser?> get userSubscription => _userSubscription;

  void userChangedEvent({required HSUser? user}) =>
      add(HSAuthenticationUserChangedEvent(user: user));

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}
