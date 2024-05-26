part of 'hs_board_bloc.dart';

sealed class HSBoardEvent extends Equatable {
  const HSBoardEvent();

  @override
  List<Object> get props => [];
}

final class HSBoardInitialEvent extends HSBoardEvent {}

final class HSBoardInitialLoading extends HSBoardEvent {}
