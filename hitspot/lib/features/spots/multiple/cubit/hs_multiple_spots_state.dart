part of 'hs_multiple_spots_cubit.dart';

enum HsMultipleSpotsStatus { initial, loading, loaded, error }

enum HsMultipleSpotsView { list, grid }

enum HsMultipleSpotsSort { name, distance }

enum HSMultipleSpotsType {
  userSpots,
  trendingSpots,
  trendingBoards,
  nearbySpots;

  static HSMultipleSpotsType fromHomeType(HomeGridBuilderType homeType) {
    switch (homeType) {
      case HomeGridBuilderType.nearbySpots:
        return HSMultipleSpotsType.nearbySpots;
      case HomeGridBuilderType.trendingBoards:
        return HSMultipleSpotsType.trendingBoards;
      default:
        return HSMultipleSpotsType.trendingSpots;
    }
  }
}

final class HsMultipleSpotsState extends Equatable {
  const HsMultipleSpotsState({
    this.status = HsMultipleSpotsStatus.initial,
    this.view = HsMultipleSpotsView.list,
    this.sort = HsMultipleSpotsSort.name,
    this.type = HSMultipleSpotsType.userSpots,
    this.spots = const <HSSpot>[],
    this.user = const HSUser(),
  });

  final HsMultipleSpotsStatus status;
  final HsMultipleSpotsView view;
  final HsMultipleSpotsSort sort;
  final HSMultipleSpotsType type;
  final List<HSSpot> spots;
  final HSUser user;

  @override
  List<Object> get props => [
        status,
        view,
        sort,
        type,
        spots,
        user,
      ];

  HsMultipleSpotsState copyWith({
    HsMultipleSpotsStatus? status,
    HsMultipleSpotsView? view,
    HsMultipleSpotsSort? sort,
    HSMultipleSpotsType? type,
    List<HSSpot>? spots,
    HSUser? user,
  }) {
    return HsMultipleSpotsState(
      status: status ?? this.status,
      view: view ?? this.view,
      sort: sort ?? this.sort,
      type: type ?? this.type,
      spots: spots ?? this.spots,
      user: user ?? this.user,
    );
  }
}
