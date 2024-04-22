import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'hs_profile_completion_event.dart';
part 'hs_profile_completion_state.dart';

class HSProfileCompletionBloc
    extends Bloc<HSProfileCompletionEvent, HSProfileCompletionState> {
  HSProfileCompletionBloc() : super(const HSProfileCompletionUpdateState()) {
    on<HSProfileCompletionEvent>((event, emit) {});
    on<HSProfileCompletionChangeStep>((event, emit) {
      emit(const HSProfileCompletionUpdateState().copyWith(
        step: event.step,
        fullname: event.fullname,
        username: event.username,
        bday: event.bday,
      ));
      print("""
DETAILS:
fullname: ${event.fullname},
step: ${event.step},
username: ${event.username},
bday: ${event.bday},
""");
    });
  }
}
