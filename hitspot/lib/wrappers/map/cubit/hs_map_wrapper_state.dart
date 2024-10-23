part of 'hs_map_wrapper_cubit.dart';

enum HSMapWrapperStatus {
  initial,
  loading,
  initialised,
  loaded,
  refreshing,
  error,
  nearby,
  saving,
  openingDirections,
  sharing,
  ignoringRefresh,
}

final class HSMapWrapperState extends Equatable {
  const HSMapWrapperState({
    this.status = HSMapWrapperStatus.initial,
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
    this.savedSpots = const [],
    this.mapType = MapType.normal,
    this.isInitialised = false,
  });

  final HSMapWrapperStatus status;
  final List<HSSpot> visibleSpots, cachedSpots;
  final Set<Marker> markers;
  final CameraPosition cameraPosition;
  final HSSpotMarkerLevel markerLevel;
  final HSSpot selectedSpot;
  final List<String> filters;
  final List<HSSpot> savedSpots;
  final MapType mapType;
  final bool isInitialised;

  bool get isSpotSelected => selectedSpot.sid != null;
  bool get isSaving => status == HSMapWrapperStatus.saving;
  bool get isLoaded => status == HSMapWrapperStatus.loaded;
  bool get isSharing => status == HSMapWrapperStatus.sharing;
  bool get isOpeningDirections =>
      status == HSMapWrapperStatus.openingDirections;

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
        savedSpots,
        mapType,
        isInitialised
      ];

  HSMapWrapperState copyWith({
    HSMapWrapperStatus? status,
    List<HSSpot>? visibleSpots,
    Set<Marker>? markers,
    CameraPosition? cameraPosition,
    List<HSSpot>? cachedSpots,
    HSSpotMarkerLevel? markerLevel,
    HSSpot? selectedSpot,
    List<String>? filters,
    List<HSSpot>? savedSpots,
    MapType? mapType,
    bool? isInitialised,
  }) {
    return HSMapWrapperState(
      status: status ?? this.status,
      visibleSpots: visibleSpots ?? this.visibleSpots,
      markers: markers ?? this.markers,
      cachedSpots: cachedSpots ?? this.cachedSpots,
      cameraPosition: cameraPosition ?? this.cameraPosition,
      markerLevel: markerLevel ?? this.markerLevel,
      selectedSpot: selectedSpot ?? this.selectedSpot,
      filters: filters ?? this.filters,
      savedSpots: savedSpots ?? this.savedSpots,
      mapType: mapType ?? this.mapType,
      isInitialised: isInitialised ?? this.isInitialised,
    );
  }
}
