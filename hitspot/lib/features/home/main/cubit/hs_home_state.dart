part of 'hs_home_cubit.dart';

enum HSHomeStatus { loading, idle, error, refreshing }

final class HSHomeState extends Equatable {
  const HSHomeState({
    this.status = HSHomeStatus.loading,
    this.tredingBoards = const [],
    this.nearbySpots = const [],
  });

  final HSHomeStatus status;
  final List<HSBoard> tredingBoards;
  final List<HSSpot> nearbySpots;

  @override
  List<Object> get props => [status, tredingBoards, nearbySpots];

  HSHomeState copyWith({
    HSHomeStatus? status,
    List<HSBoard>? tredingBoards,
    List<HSSpot>? nearbySpots,
  }) {
    return HSHomeState(
      status: status ?? this.status,
      tredingBoards: tredingBoards ?? this.tredingBoards,
      nearbySpots: nearbySpots ?? this.nearbySpots,
    );
  }
}
