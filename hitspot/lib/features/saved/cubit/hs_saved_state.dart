part of 'hs_saved_cubit.dart';

enum HSSavedStatus { loading, idle, error }

final class HSSavedState extends Equatable {
  const HSSavedState(
      {this.status = HSSavedStatus.loading,
      this.savedBoards = const [],
      this.savedSpots = const [],
      this.ownBoards = const []});

  final HSSavedStatus status;
  final List<HSBoard> savedBoards;
  final List<HSBoard> ownBoards;
  final List<HSSpot> savedSpots;

  @override
  List<Object> get props => [status, savedBoards, ownBoards, savedSpots];

  HSSavedState copyWith({
    HSSavedStatus? status,
    List<HSBoard>? savedBoards,
    List<HSBoard>? ownBoards,
    List<HSSpot>? savedSpots,
  }) {
    return HSSavedState(
      status: status ?? this.status,
      savedBoards: savedBoards ?? this.savedBoards,
      ownBoards: ownBoards ?? this.ownBoards,
      savedSpots: savedSpots ?? this.savedSpots,
    );
  }
}
