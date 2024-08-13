part of 'hs_home_cubit.dart';

enum HSHomeStatus { loading, idle, error, refreshing, updateRequired }

final class HSHomeState extends Equatable {
  const HSHomeState({
    this.status = HSHomeStatus.loading,
    this.trendingBoards = const [],
    this.markers = const [],
    this.nearbySpots = const [],
    this.trendingSpots = const [],
    this.currentPosition,
    this.hideUploadBar = false,
  });

  final HSHomeStatus status;
  final List<HSBoard> trendingBoards;
  final List<HSSpot> nearbySpots, trendingSpots;
  final List<Marker> markers;
  final Position? currentPosition;
  final bool hideUploadBar;

  @override
  List<Object?> get props => [
        status,
        trendingBoards,
        nearbySpots,
        currentPosition,
        markers,
        trendingSpots,
        hideUploadBar,
      ];

  HSHomeState copyWith({
    HSHomeStatus? status,
    List<HSBoard>? tredingBoards,
    List<HSSpot>? nearbySpots,
    List<HSSpot>? trendingSpots,
    Position? currentPosition,
    List<Marker>? markers,
    bool? hideUploadBar,
  }) {
    return HSHomeState(
      status: status ?? this.status,
      trendingBoards: tredingBoards ?? trendingBoards,
      nearbySpots: nearbySpots ?? this.nearbySpots,
      currentPosition: currentPosition ?? this.currentPosition,
      markers: markers ?? this.markers,
      trendingSpots: trendingSpots ?? this.trendingSpots,
      hideUploadBar: hideUploadBar ?? this.hideUploadBar,
    );
  }
}
