part of 'hs_cluster_map_cubit.dart';

enum HSClusterMapStatus { initial, loading, loaded, refreshing, error }

final class HsClusterMapState extends Equatable {
  const HsClusterMapState({
    this.status = HSClusterMapStatus.initial,
    this.visibleSpots = const [],
    this.markers = const {},
    this.cachedSpots = const [],
  });

  final HSClusterMapStatus status;
  final List<HSSpot> visibleSpots, cachedSpots;
  final Set<Marker> markers;

  @override
  List<Object> get props => [status, visibleSpots, markers, cachedSpots];

  HsClusterMapState copyWith(
      {HSClusterMapStatus? status,
      List<HSSpot>? visibleSpots,
      Set<Marker>? markers,
      List<HSSpot>? cachedSpots}) {
    return HsClusterMapState(
        status: status ?? this.status,
        visibleSpots: visibleSpots ?? this.visibleSpots,
        markers: markers ?? this.markers,
        cachedSpots: cachedSpots ?? this.cachedSpots);
  }
}
