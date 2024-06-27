part of 'hs_home_cubit.dart';

enum HSHomeStatus { loading, idle, error, refreshing }

final class HSHomeState extends Equatable {
  const HSHomeState({
    this.status = HSHomeStatus.loading,
    this.tredingBoards = const [],
    this.nearbySpots = const [],
    this.currentPosition,
  });

  final HSHomeStatus status;
  final List<HSBoard> tredingBoards;
  final List<HSSpot> nearbySpots;
  final Position? currentPosition;

  @override
  List<Object?> get props =>
      [status, tredingBoards, nearbySpots, currentPosition];

  HSHomeState copyWith({
    HSHomeStatus? status,
    List<HSBoard>? tredingBoards,
    List<HSSpot>? nearbySpots,
    Position? currentPosition,
  }) {
    return HSHomeState(
      status: status ?? this.status,
      tredingBoards: tredingBoards ?? this.tredingBoards,
      nearbySpots: nearbySpots ?? this.nearbySpots,
      currentPosition: currentPosition ?? this.currentPosition,
    );
  }
}
