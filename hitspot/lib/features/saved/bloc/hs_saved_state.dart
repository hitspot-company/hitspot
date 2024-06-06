part of 'hs_saved_bloc.dart';

sealed class HSSavedState extends Equatable {
  const HSSavedState();

  @override
  List<Object> get props => [];
}

final class HSSavedInitialState extends HSSavedState {}

final class HSSavedReadyState extends HSSavedState {
  const HSSavedReadyState(
      {required this.savedBoards, required this.userBoards});
  final List<HSBoard> savedBoards;
  final List<HSBoard> userBoards;

  @override
  List<Object> get props => [savedBoards, userBoards];
}
