part of 'hs_boards_bloc.dart';

sealed class HSBoardsState extends Equatable {
  const HSBoardsState();

  @override
  List<Object> get props => [];
}

final class HSBoardsInitial extends HSBoardsState {}
