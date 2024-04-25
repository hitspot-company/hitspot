import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get/get.dart';
import 'package:hitspot/models/hs_user.dart';
import 'package:hitspot/repositories/hs_authentication_repository.dart';

part 'hs_app_state.dart';
part 'hs_app_events.dart';

class HSAppBloc extends Bloc<HSAppEvent, HSAppState> {
  final HSAuthenticationRepository _authenticationRepository;
  late final StreamSubscription<HSUser?> _userSubscription;

  // TODO: Add emitting not completed state
  HSAppBloc({required HSAuthenticationRepository authenticationRepository})
      : _authenticationRepository = authenticationRepository,
        super(
          authenticationRepository.currentUser != null
              ? HSAppState.authenticated(authenticationRepository.currentUser!)
              : const HSAppState.unauthenticated(),
        ) {
    on<_HSAppUserChanged>(_onUserChanged);

    on<HSAppLogoutRequested>(_onLogoutRequested);

    _userSubscription = _authenticationRepository.user.listen(
      (user) => add(_HSAppUserChanged(user)),
    );
  }

  void _onUserChanged(_HSAppUserChanged event, Emitter<HSAppState> emit) {
    HSAppState state = const HSAppState.unauthenticated();

    if (event.user != null) {
      if (event.user!.isProfileCompleted!) {
        state = HSAppState.authenticated(event.user!);
      } else {
        state = HSAppState.profileNotCompleted(event.user!);
      }
    }
    emit(state);
  }

  void _onLogoutRequested(
      HSAppLogoutRequested event, Emitter<HSAppState> emit) {
    unawaited(_authenticationRepository.logOut());
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}
