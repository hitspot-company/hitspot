part of 'hs_saved_cubit.dart';

enum HSSavedStatus { loading, idle, error }

final class HSSavedState extends Equatable {
  const HSSavedState(
      {this.status = HSSavedStatus.loading,
      this.savedBoards = const [],
      this.savedSpots = const [],
      this.ownBoards = const [],
      this.query = "",
      this.searchedBoardsResults = const [],
      this.searchedSavedBoardsResults = const [],
      this.searchedSavedSpotsResults = const [],
      this.batchOffset = 0});

  final HSSavedStatus status;
  final List<HSBoard> savedBoards;
  final List<HSBoard> ownBoards;
  final List<HSSpot> savedSpots;

  final String query;
  final List<HSBoard> searchedBoardsResults;
  final List<HSBoard> searchedSavedBoardsResults;
  final List<HSSpot> searchedSavedSpotsResults;

  final int batchOffset;

  @override
  List<Object> get props => [
        status,
        savedBoards,
        ownBoards,
        savedSpots,
        query,
        searchedBoardsResults,
        searchedSavedBoardsResults,
        searchedSavedSpotsResults,
        batchOffset
      ];

  HSSavedState copyWith({
    HSSavedStatus? status,
    List<HSBoard>? savedBoards,
    List<HSBoard>? ownBoards,
    List<HSSpot>? savedSpots,
    String? query,
    List<HSBoard>? searchedBoardsResults,
    List<HSBoard>? searchedSavedBoardsResults,
    List<HSSpot>? searchedSavedSpotsResults,
    int? batchOffset,
  }) {
    return HSSavedState(
      status: status ?? this.status,
      savedBoards: savedBoards ?? this.savedBoards,
      ownBoards: ownBoards ?? this.ownBoards,
      savedSpots: savedSpots ?? this.savedSpots,
      query: query ?? this.query,
      searchedBoardsResults:
          searchedBoardsResults ?? this.searchedBoardsResults,
      searchedSavedBoardsResults:
          searchedSavedBoardsResults ?? this.searchedSavedBoardsResults,
      searchedSavedSpotsResults:
          searchedSavedSpotsResults ?? this.searchedSavedSpotsResults,
      batchOffset: batchOffset ?? this.batchOffset,
    );
  }
}
