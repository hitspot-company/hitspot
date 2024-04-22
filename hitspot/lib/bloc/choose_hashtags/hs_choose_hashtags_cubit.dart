import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'hs_choose_hashtags_state.dart';

class HSChooseHashtagsCubit extends Cubit<HSChooseHashtagsState> {
  HSChooseHashtagsCubit() : super(const HSChooseHashtagsUpdate());

  void updateChosen(List<Object?> newChosen) =>
      emit(state.copyWith(chosenHashtags: newChosen));
}
