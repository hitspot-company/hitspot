import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';

part 'hs_authentication_state.dart';
part 'hs_authentication_events.dart';

class HSAuthenticationBloc
    extends Bloc<HSAuthenticationEvent, HSAuthenticationState> {
  final HSAuthenticationRepository _authenticationRepository;
  late final StreamSubscription<HSUser?> _userSubscription;

  final HSDatabaseRepository _databaseRepository;

  HSAuthenticationBloc(
      {required HSDatabaseRepository databaseRepository,
      required HSAuthenticationRepository authenticationRepository})
      : _authenticationRepository = authenticationRepository,
        _databaseRepository = databaseRepository,
        super(const HSAuthenticationState.loading()) {
    on<HSAppUserChanged>(_onUserChanged);
    on<HSAppLogoutRequested>(_onLogoutRequested);
    _delayedUserStreamSubscription();
  }

  /// Used to artificially prolong splash screen time
  Future<void> _delayedUserStreamSubscription() async {
    // await Future.delayed(const Duration(seconds: 3));
    _userSubscription = _authenticationRepository.user.listen(
      (user) => add(HSAppUserChanged(user)),
    );
  }

  void _onUserChanged(
      HSAppUserChanged event, Emitter<HSAuthenticationState> emit) async {
    HSAuthenticationState state = const HSAuthenticationState.unauthenticated();

    if (event.user != null) {
      HSUser? newUser;
      try {
        newUser =
            await _databaseRepository.getUserFromDatabase(event.user!.uid!);

        // If user's document does not exist in database, create it
        if (newUser == null) {
          await _databaseRepository.updateUserInfoInDatabase(event.user!);
          newUser = event.user!;
          HSDebugLogger.logSuccess("Added user info to database!");
        } else {
          HSDebugLogger.logSuccess("Fetched user info from database!");
        }
        _authenticationRepository.currentUser = newUser;
      } catch (_) {
        emit(state);
        return;
      }
      if (newUser.isEmailVerified != true) {
        state = const HSAuthenticationState.emailNotVerified();
      } else if (newUser.isProfileCompleted != true) {
        state = HSAuthenticationState.profileNotCompleted(newUser);
      } else {
        state = HSAuthenticationState.authenticated(newUser);
      }
    }
    emit(state);
  }

  void _onLogoutRequested(
      HSAppLogoutRequested event, Emitter<HSAuthenticationState> emit) {
    unawaited(_authenticationRepository.logOut());
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}
