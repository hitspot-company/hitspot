import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hitspot/profile_incomplete/view/profile_completion_form.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:hs_form_inputs/hs_form_inputs.dart';

part 'hs_profile_completion_state.dart';

class HSProfileCompletionCubit extends Cubit<HSProfileCompletionState> {
  final HSDatabaseRepository _hsDatabaseRepository;
  HSProfileCompletionCubit(this._hsDatabaseRepository)
      : super(const HSProfileCompletionState());

  void onStepContinue() {
    // The confirmation step
    if (state.step != 3) {
      emit(state.copyWith(step: state.step + 1, error: ""));
    } else {
      print("Confirm");
    }
  }

  void onStepCancel() {
    // The first step
    if (state.step != 0) {
      emit(state.copyWith(step: state.step - 1, error: ""));
    } else {
      print("Zero reached");
    }
  }

  void updateStep(int newStep) => emit(state.copyWith(step: newStep));

  void updateUsername(String newUsername) async => emit(state.copyWith(
      username: Username.dirty(newUsername),
      usernameAvailable: await updateUsernameAvailable(newUsername)));

  void updateFullname(String newFullname) =>
      emit(state.copyWith(fullname: Fullname.dirty(newFullname)));

  void updateBirthday(String newBirthday) =>
      emit(state.copyWith(birthday: newBirthday));

  Future<bool> updateUsernameAvailable(String newUsername) async =>
      await _hsDatabaseRepository.isUsernameAvailable(newUsername);

  Future<void> completeUserProfile(HSUser currentUser) async {
    try {
      if (!fieldsValid()) return;
      final HSUser updatedUser = currentUser.copyWith(
        birthday: state.birthday.dateTimeStringToTimestamp(),
        username: state.username.value,
        fullName: state.fullname.value,
        isProfileCompleted: true,
      );
      await _hsDatabaseRepository.completeUserProfile(updatedUser);
      emit(state.copyWith(pageComplete: true));
    } catch (_) {
      HSDebugLogger.logError(_.toString());
    }
  }

  bool fieldsValid() {
    try {
      final DateTime now = DateTime.now();
      final DateTime minimalAge = DateTime(now.year - 18, now.month, now.day);
      if (state.birthday.stringToDateTime().isBefore(minimalAge)) {
        throw "You have to be at least 18 to use Hitspot";
      }
      if (!state.usernameAvailable) {
        throw "The username is not available";
      }
      if (state.fullname.displayError != null) {
        throw "The name is invalid";
      }
      return (true);
    } catch (_) {
      emit(state.copyWith(error: _.toString()));
      emit(state.copyWith(error: ""));
      HSDebugLogger.logError(_.toString());
    }
    return (false);
  }
}
