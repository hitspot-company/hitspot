part of 'hs_board_bloc.dart';

sealed class HSBoardState extends Equatable {
  const HSBoardState();

  @override
  List<Object> get props => [];
}

final class HSBoardInitialState extends HSBoardState {}

final class HSBoardReadyState extends HSBoardState {
  const HSBoardReadyState({required this.author, required this.board});
  final HSUser author;
  final HSBoard board;

  @override
  List<Object> get props => [author, board];
}

final class HSBoardErrorState extends HSBoardState {
  const HSBoardErrorState(this.error);
  final String error;

  @override
  List<Object> get props => [error];
}
