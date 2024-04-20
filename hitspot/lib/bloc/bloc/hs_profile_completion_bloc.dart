import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hitspot/models/hs_user.dart';

part 'hs_profile_completion_event.dart';
part 'hs_profile_completion_state.dart';

class HSProfileCompletionBloc
    extends Bloc<HSProfileCompletionEvent, HSProfileCompletionState> {
  HSProfileCompletionBloc() : super(HSProfileCompletionInitialStep()) {
    on<HSProfileCompletionEvent>((event, emit) {});
    on<HSProfileCompletionNextStepEvent>((event, emit) {
      switch (event.step) {
        case 0:
          emit(const HSProfileCompletionFullnameStep());
          break;
        case 1:
          emit(const HSProfileCompletionUsernameStep());
          break;
        case 2:
          emit(const HSProfileCompletionConfirmationStep());
          break;
      }
    });
    on<HSProfileCompletionPreviousStepEvent>((event, emit) {
      switch (event.step) {
        case 1:
          emit(HSProfileCompletionBirtdayStep());
          break;
        case 2:
          emit(HSProfileCompletionFullnameStep());
          break;
        case 3:
          emit(HSProfileCompletionUsernameStep());
          break;
      }
    });
  }
}
