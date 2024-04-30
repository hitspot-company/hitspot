import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      emit(state.copyWith(step: state.step + 1));
    } else {
      print("Confirm");
    }
  }

  void onStepCancel() {
    // The first step
    if (state.step != 0) {
      emit(state.copyWith(step: state.step - 1));
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
      final HSUser updatedUser = currentUser.copyWith(
        birthday: state.birthday.dateTimeStringToTimestamp(),
        username: state.username.value,
        fullName: state.fullname.value,
      );
      await _hsDatabaseRepository.completeUserProfile(updatedUser);
      await FirebaseAuth.instance.currentUser!.reload();
    } catch (_) {
      HSDebugLogger.logError(_.toString());
    }
  }
}
