part of 'hs_cluster_map_cubit.dart';

enum HSClusterMapStatus { initial, loading, loaded, refreshing, error, nearby }

final class HsClusterMapState extends Equatable {
  const HsClusterMapState({
    this.status = HSClusterMapStatus.initial,
    this.visibleSpots = const [],
    this.markers = const {},
    this.cachedSpots = const [],
    this.markerLevel = HSSpotMarkerLevel.high,
    this.cameraPosition = const CameraPosition(
      target: LatLng(0, 0),
      zoom: 0,
    ),
    this.selectedSpot = const HSSpot(),
    this.filters = const [],
  });

  final HSClusterMapStatus status;
  final List<HSSpot> visibleSpots, cachedSpots;
  final Set<Marker> markers;
  final CameraPosition cameraPosition;
  final HSSpotMarkerLevel markerLevel;
  final HSSpot selectedSpot;
  final List<String> filters;

  bool get isSpotSelected => selectedSpot.sid != null;

  @override
  List<Object> get props => [
        status,
        visibleSpots,
        markers,
        cachedSpots,
        cameraPosition,
        markerLevel,
        selectedSpot,
        filters,
      ];

  HsClusterMapState copyWith({
    HSClusterMapStatus? status,
    List<HSSpot>? visibleSpots,
    Set<Marker>? markers,
    CameraPosition? cameraPosition,
    List<HSSpot>? cachedSpots,
    HSSpotMarkerLevel? markerLevel,
    HSSpot? selectedSpot,
    List<String>? filters,
  }) {
    return HsClusterMapState(
      status: status ?? this.status,
      visibleSpots: visibleSpots ?? this.visibleSpots,
      markers: markers ?? this.markers,
      cachedSpots: cachedSpots ?? this.cachedSpots,
      cameraPosition: cameraPosition ?? this.cameraPosition,
      markerLevel: markerLevel ?? this.markerLevel,
      selectedSpot: selectedSpot ?? this.selectedSpot,
      filters: filters ?? this.filters,
    );
  }
}
