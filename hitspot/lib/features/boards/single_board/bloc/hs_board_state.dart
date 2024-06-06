part of 'hs_board_bloc.dart';

enum HSBoardSaveState { saved, unsaved, updating }

sealed class HSBoardState extends Equatable {
  const HSBoardState();

  @override
  List<Object?> get props => [];
}

final class HSBoardInitialState extends HSBoardState {}

final class HSBoardReadyState extends HSBoardState {
  const HSBoardReadyState(
      {required this.author,
      required this.board,
      required this.boardSaveState});

  final HSUser author;
  final HSBoard board;
  final HSBoardSaveState boardSaveState;

  @override
  List<Object?> get props => [author, board, boardSaveState];
}

final class HSBoardErrorState extends HSBoardState {
  const HSBoardErrorState(this.error);
  final String error;

  @override
  List<Object> get props => [error];
}
