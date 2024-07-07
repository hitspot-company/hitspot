part of 'hs_map_cubit.dart';

enum HSMapStatus { initial, loading, fetchingSpots, error, success }

final class HSMapState extends Equatable {
  const HSMapState({
    this.spotsInView = const [],
    this.markersInView = const [],
    this.status = HSMapStatus.initial,
    this.currentPosition,
    this.cameraPosition,
    this.bounds,
    this.isMoving = false,
    this.selectedSpot = const HSSpot(),
    this.sheetExpansionStatus = ExpansionStatus.contracted,
    this.infoWindowProvider = const HSInfoWindowProvider(),
  });

  final HSMapStatus status;
  final List<HSSpot> spotsInView;
  final List<Marker> markersInView;
  final Position? currentPosition;
  final LatLng? cameraPosition;
  final LatLngBounds? bounds;
  final ExpansionStatus sheetExpansionStatus;
  final HSInfoWindowProvider infoWindowProvider;
  final bool isMoving;
  final HSSpot selectedSpot;

  HSSpot? get currentlySelectedSpot =>
      selectedSpot.title == null ? null : selectedSpot;

  @override
  List<Object?> get props => [
        spotsInView,
        status,
        currentPosition,
        cameraPosition,
        bounds,
        markersInView,
        sheetExpansionStatus,
        infoWindowProvider,
        isMoving,
        selectedSpot,
      ];

  HSMapState copyWith({
    List<HSSpot>? spotsInView,
    HSMapStatus? status,
    Position? currentPosition,
    LatLng? cameraPosition,
    LatLngBounds? bounds,
    List<Marker>? markersInView,
    ExpansionStatus? sheetExpansionStatus,
    HSInfoWindowProvider? infoWindowProvider,
    bool? isMoving,
    HSSpot? selectedSpot,
  }) {
    return HSMapState(
      spotsInView: spotsInView ?? this.spotsInView,
      markersInView: markersInView ?? this.markersInView,
      status: status ?? this.status,
      currentPosition: currentPosition ?? this.currentPosition,
      cameraPosition: cameraPosition ?? this.cameraPosition,
      bounds: bounds ?? this.bounds,
      sheetExpansionStatus: sheetExpansionStatus ?? this.sheetExpansionStatus,
      infoWindowProvider: infoWindowProvider ?? this.infoWindowProvider,
      isMoving: isMoving ?? this.isMoving,
      selectedSpot: getSelectedSpot(selectedSpot) ?? this.selectedSpot,
    );
  }

  HSSpot? getSelectedSpot(HSSpot? spot) {
    if (spot != null && spot.title == null) return null;
    return spot;
  }
}
