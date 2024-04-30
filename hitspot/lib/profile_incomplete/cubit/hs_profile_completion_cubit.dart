import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_form_inputs/hs_form_inputs.dart';

part 'hs_profile_completion_state.dart';

class HSProfileCompletionCubit extends Cubit<HSProfileCompletionState> {
  final HSDatabaseRepository _hsDatabaseRepository;
  HSProfileCompletionCubit(this._hsDatabaseRepository)
      : super(const HSProfileCompletionState());

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
}
