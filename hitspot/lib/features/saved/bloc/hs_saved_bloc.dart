import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hs_database_repository/hs_database_repository.dart';

part 'hs_saved_event.dart';
part 'hs_saved_state.dart';

class HSSavedBloc extends Bloc<HSSavedEvent, HSSavedState> {
  HSSavedBloc() : super(HSSavedInitialState()) {
    on<HSSavedFetchInitial>(_fetchInitial);
  }

  final HSDatabaseRepository _databaseRepository = app.databaseRepository;

  Future<void> _fetchInitial(event, emit) async {
    try {
      final user =
          await _databaseRepository.getUserFromDatabase(currentUser.uid!);
      if (user == null) throw "Error";
      final List<HSBoard> userBoards =
          await _databaseRepository.getUserBoards(user: user);
      final List<HSBoard> savedBoards =
          await _databaseRepository.getSavedBoards(user: user);
      emit(HSSavedReadyState(savedBoards: savedBoards, userBoards: userBoards));
    } catch (_) {
      navi.toError("Error", "Could not fetch saved boards");
    }
  }
}
