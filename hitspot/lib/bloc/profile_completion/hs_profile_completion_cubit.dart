import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'hs_profile_completion_state.dart';

class HSProfileCompletionCubit extends Cubit<HSProfileCompletionState> {
  HSProfileCompletionCubit() : super(const HSProfileCompletionUpdate());

  void updateBirthdate(String newDate) => emit(state.copyWith(bday: newDate));

  void updateFullname(String newFullname) =>
      emit(state.copyWith(fullname: newFullname));

  void updateUsername(String newUsername) =>
      emit(state.copyWith(username: newUsername));

  void updatePreferences(List<Object?> newPreferences) {
    print("Current preferences: ${state.preferences}");
    print("New preferences: ${newPreferences}");
    emit(state.copyWith(preferences: newPreferences));
  }

  void changeStep(int newStep) => emit(state.copyWith(step: newStep));
}
