part of 'hs_single_board_map_cubit.dart';

enum HSSingleBoardMapStatus { initial, loading, loaded, error }

final class HSSingleBoardMapState extends Equatable {
  const HSSingleBoardMapState({
    this.spots = const <HSSpot>[],
    this.status = HSSingleBoardMapStatus.initial,
    this.currentPosition,
    this.markers = const <Marker>{},
  });

  final List<HSSpot> spots;
  final HSSingleBoardMapStatus status;
  final Position? currentPosition;
  final Set<Marker> markers;

  @override
  List<Object?> get props => [spots, status, currentPosition, markers];

  HSSingleBoardMapState copyWith({
    List<HSSpot>? spots,
    HSSingleBoardMapStatus? status,
    Position? currentPosition,
    Set<Marker>? markers,
  }) {
    return HSSingleBoardMapState(
      spots: spots ?? this.spots,
      status: status ?? this.status,
      currentPosition: currentPosition ?? this.currentPosition,
      markers: markers ?? this.markers,
    );
  }
}
