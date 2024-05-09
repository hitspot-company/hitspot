import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:hs_mailing_repository/hs_mailing_repository.dart';

part 'hs_authentication_state.dart';
part 'hs_authentication_events.dart';

class HSAuthenticationBloc
    extends Bloc<HSAuthenticationEvent, HSAuthenticationState> {
  final HSAuthenticationRepository _authenticationRepository;
  final HSMailingRepository _mailingRepository;
  late final StreamSubscription<HSUser?> _userSubscription;

  final HSDatabaseRepository _databaseRepository;

  HSAuthenticationBloc(
      {required HSDatabaseRepository databaseRepository,
      required HSAuthenticationRepository authenticationRepository,
      required HSMailingRepository mailingRepository})
      : _authenticationRepository = authenticationRepository,
        _databaseRepository = databaseRepository,
        _mailingRepository = mailingRepository,
        super(const HSAuthenticationState.loading()) {
    on<HSAppUserChanged>(_onUserChanged);
    on<HSAppLogoutRequested>(_onLogoutRequested);
    _delayedUserStreamSubscription();
  }

  /// Used to artificially prolong splash screen time
  Future<void> _delayedUserStreamSubscription() async {
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
          await _sendGreetingEmail(event.user);
          newUser = event.user!;
          HSDebugLogger.logSuccess("Added user info to database!");
        } else {
          HSDebugLogger.logSuccess("Fetched user info from database!");
        }
        _authenticationRepository.currentUser = newUser;
      } on HSSendEmailException catch (e) {
        HSDebugLogger.logError(e.message);
        emit(state);
        return;
      } catch (_) {
        HSDebugLogger.logError(_.toString());
        emit(state);
        return;
      }
      if (newUser.isEmailVerified != true) {
        state = HSAuthenticationState.emailNotVerified(newUser);
      } else if (newUser.isProfileCompleted != true) {
        state = HSAuthenticationState.profileNotCompleted(newUser);
      } else {
        state = HSAuthenticationState.authenticated(newUser);
      }
    }
    emit(state);
  }

  Future<void> _sendGreetingEmail(HSUser? user) async {
    if (user?.email != null) {
      // Send welcoming email if user created
      Response response = await _mailingRepository.sendEmail(
        HSMailType.welcome,
        emailTo: user!.email!,
        emailFrom: "Hitspot Onboarding <onboarding@send.hitspot.app>",
      );
      HSDebugLogger.logSuccess("Email sent! code: ${response.statusCode}");
    }
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
