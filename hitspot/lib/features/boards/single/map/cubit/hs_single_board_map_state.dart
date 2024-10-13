part of 'hs_single_board_map_cubit.dart';

enum HSSingleBoardMapStatus { initial, loading, loaded, error }

final class HSSingleBoardMapState extends Equatable {
  const HSSingleBoardMapState({
    this.status = HSSingleBoardMapStatus.initial,
    this.currentPosition,
  });

  final HSSingleBoardMapStatus status;
  final Position? currentPosition;

  @override
  List<Object?> get props => [status, currentPosition];

  HSSingleBoardMapState copyWith({
    List<HSSpot>? spots,
    HSSingleBoardMapStatus? status,
    Position? currentPosition,
    Set<Marker>? markers,
    CameraPosition? cameraPosition,
    HSSpotMarkerLevel? markerLevel,
  }) {
    return HSSingleBoardMapState(
      status: status ?? this.status,
      currentPosition: currentPosition ?? this.currentPosition,
    );
  }
}
