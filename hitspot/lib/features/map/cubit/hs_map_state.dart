part of 'hs_map_cubit.dart';

enum HSMapStatus { initial, loading, fetchingSpots, error, success }

final class HsMapState extends Equatable {
  const HsMapState({
    this.spotsInView = const [],
    this.status = HSMapStatus.initial,
    this.currentPosition,
    this.cameraPosition,
    this.bounds,
  });

  final HSMapStatus status;
  final List<HSSpot> spotsInView;
  final Position? currentPosition;
  final LatLng? cameraPosition;
  final LatLngBounds? bounds;

  @override
  List<Object?> get props =>
      [spotsInView, status, currentPosition, cameraPosition, bounds];

  HsMapState copyWith({
    List<HSSpot>? spotsInView,
    HSMapStatus? status,
    Position? currentPosition,
    LatLng? cameraPosition,
    LatLngBounds? bounds,
  }) {
    return HsMapState(
      spotsInView: spotsInView ?? this.spotsInView,
      status: status ?? this.status,
      currentPosition: currentPosition ?? this.currentPosition,
      cameraPosition: cameraPosition ?? this.cameraPosition,
      bounds: bounds ?? this.bounds,
    );
  }
}
