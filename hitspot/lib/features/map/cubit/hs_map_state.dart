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
  });

  final HSMapStatus status;
  final List<HSSpot> spotsInView;
  final List<Marker> markersInView;
  final Position? currentPosition;
  final LatLng? cameraPosition;
  final LatLngBounds? bounds;

  @override
  List<Object?> get props => [
        spotsInView,
        status,
        currentPosition,
        cameraPosition,
        bounds,
        markersInView
      ];

  HSMapState copyWith({
    List<HSSpot>? spotsInView,
    HSMapStatus? status,
    Position? currentPosition,
    LatLng? cameraPosition,
    LatLngBounds? bounds,
    List<Marker>? markersInView,
  }) {
    return HSMapState(
      spotsInView: spotsInView ?? this.spotsInView,
      markersInView: markersInView ?? this.markersInView,
      status: status ?? this.status,
      currentPosition: currentPosition ?? this.currentPosition,
      cameraPosition: cameraPosition ?? this.cameraPosition,
      bounds: bounds ?? this.bounds,
    );
  }
}
