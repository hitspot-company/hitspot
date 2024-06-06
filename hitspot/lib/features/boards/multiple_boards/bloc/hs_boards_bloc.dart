import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'hs_boards_event.dart';
part 'hs_boards_state.dart';

class HSBoardsBloc extends Bloc<HSBoardsEvent, HSBoardsState> {
  HSBoardsBloc() : super(HSBoardsInitial()) {
    on<HSBoardsEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
