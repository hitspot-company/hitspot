import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';

part 'hs_authentication_state.dart';
part 'hs_authentication_events.dart';

class HSAuthenticationBloc
    extends Bloc<HSAuthenticationEvent, HSAuthenticationState> {
  final HSAuthenticationRepository _authenticationRepository;
  late final StreamSubscription<HSUser?> _userSubscription;

  HSAuthenticationBloc(
      {required HSAuthenticationRepository authenticationRepository})
      : _authenticationRepository = authenticationRepository,
        super(const HSAuthenticationState.loading()) {
    on<_HSAppUserChanged>(_onUserChanged);
    on<HSAppLogoutRequested>(_onLogoutRequested);
    _delayedUserStreamSubscription();
  }

  /// Used to artificially prolong splash screen time
  Future<void> _delayedUserStreamSubscription() async {
    await Future.delayed(const Duration(seconds: 3));
    _userSubscription = _authenticationRepository.user.listen(
      (user) => add(_HSAppUserChanged(user)),
    );
  }

  void _onUserChanged(
      _HSAppUserChanged event, Emitter<HSAuthenticationState> emit) async {
    HSAuthenticationState state = const HSAuthenticationState.unauthenticated();

    if (event.user != null) {
      if (event.user!.isProfileCompleted ?? false) {
        state = HSAuthenticationState.authenticated(event.user!);
      } else {
        state = HSAuthenticationState.profileNotCompleted(event.user!);
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
