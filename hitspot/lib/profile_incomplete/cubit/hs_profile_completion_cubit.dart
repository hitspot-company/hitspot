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

  void onStepContinue() async {
    try {
      switch (state.step) {
        case 0:
          if (isBirthdateValid()) {
            emit(
                state.copyWith(step: state.step + 1, birthday: state.birthday));
          }
          break;
        case 1:
          if (await isUsernameValid()) {
            emit(
                state.copyWith(step: state.step + 1, username: state.username));
          }
          break;
        case 2:
          if (isFullnameValid()) {
            emit(
                state.copyWith(step: state.step + 1, fullname: state.fullname));
          } else {
            emitError("The full name is invalid");
          }
          break;
        case 3:
        default:
          HSDebugLogger.logInfo("Default onStepContinue");
      }
    } catch (e) {
      HSDebugLogger.logError(e.toString());
      emitError(e.toString());
    }
  }

  void emitError(String error) {
    emit(state.copyWith(error: error));
    emit(state.copyWith(error: ""));
  }

  bool isBirthdateValid() {
    final DateTime now = DateTime.now();
    final DateTime minimalAge = DateTime(now.year - 18, now.month, now.day);
    // if (state.birthday.isEmpty) {
    //   throw "Birthday cannot be empty";
    // } else if (state.birthday.stringToDateTime().isAfter(minimalAge)) {
    //   throw "You have to be at least 18 years old to use Hitspot";
    // }
    return true;
  }

  Future<bool> isUsernameValid() async {
    final String username = state.username.value;
    if (username.isEmpty) throw "Username cannot be empty";
    if (state.username.displayError != null) throw "Invalid username.";
    if (!(await _hsDatabaseRepository.isUsernameAvailable(username))) {
      emit(state.copyWith(usernameAvailable: false));
      throw "The username is unavailable. Try another one.";
    }
    return true;
  }

  bool isFullnameValid() {
    return (state.fullname.isValid);
  }

  void onStepCancel() {
    if (state.step != 0) {
      emit(state.copyWith(step: state.step - 1, error: ""));
    } else {
      HSDebugLogger.logInfo("Zero reached");
    }
  }

  void updateStep(int newStep) => emit(state.copyWith(step: newStep));

  void updateUsername(String newUsername) async => emit(state.copyWith(
      username: Username.dirty(newUsername), usernameAvailable: true));

  void updateFullname(String newFullname) =>
      emit(state.copyWith(fullname: Fullname.dirty(newFullname)));

  void updateBirthday(Birthdate newBirthday) =>
      emit(state.copyWith(birthday: newBirthday));

  Future<void> completeUserProfile(HSUser currentUser) async {
    emit(state.copyWith(loading: true));
    await Future.delayed(const Duration(seconds: 3));
    // try {
    //   final HSUser updatedUser = currentUser.copyWith(
    //     birthday: state.birthday.dateTimeStringToTimestamp(),
    //     username: state.username.value,
    //     fullName: state.fullname.value,
    //     isProfileCompleted: true,
    //   );
    //   await _hsDatabaseRepository.completeUserProfile(updatedUser);
    //   emit(state.copyWith(pageComplete: true));
    // } catch (_) {
    //   HSDebugLogger.logError(_.toString());
    // }
    emit(state.copyWith(loading: false));
  }
}
