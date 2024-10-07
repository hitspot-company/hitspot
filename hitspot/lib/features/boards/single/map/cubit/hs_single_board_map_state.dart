part of 'hs_single_board_map_cubit.dart';

enum HSSingleBoardMapStatus { initial, loading, loaded, error }

final class HSSingleBoardMapState extends Equatable {
  const HSSingleBoardMapState({
    this.spots = const <HSSpot>[],
    this.status = HSSingleBoardMapStatus.initial,
    this.currentPosition,
    this.markers = const <Marker>{},
    this.cameraPosition = const CameraPosition(
      target: LatLng(0, 0),
      zoom: 0,
    ),
    this.markerLevel = HSSpotMarkerLevel.high,
  });

  final List<HSSpot> spots;
  final HSSingleBoardMapStatus status;
  final Position? currentPosition;
  final Set<Marker> markers;
  final CameraPosition cameraPosition;
  final HSSpotMarkerLevel markerLevel;

  @override
  List<Object?> get props =>
      [spots, status, currentPosition, markers, cameraPosition, markerLevel];

  HSSingleBoardMapState copyWith({
    List<HSSpot>? spots,
    HSSingleBoardMapStatus? status,
    Position? currentPosition,
    Set<Marker>? markers,
    CameraPosition? cameraPosition,
    HSSpotMarkerLevel? markerLevel,
  }) {
    return HSSingleBoardMapState(
      spots: spots ?? this.spots,
      status: status ?? this.status,
      currentPosition: currentPosition ?? this.currentPosition,
      markers: markers ?? this.markers,
      cameraPosition: cameraPosition ?? this.cameraPosition,
      markerLevel: markerLevel ?? this.markerLevel,
    );
  }
}
