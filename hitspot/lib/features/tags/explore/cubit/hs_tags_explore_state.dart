part of 'hs_tags_explore_cubit.dart';

enum HSTagsExploreStatus {
  initial,
  loadingTopSpot,
  loadingSpots,
  loaded,
  error
}

final class HSTagsExploreState extends Equatable {
  const HSTagsExploreState({
    this.status = HSTagsExploreStatus.initial,
    this.topSpot = const HSSpot(),
    this.spots = const [],
  });

  final HSTagsExploreStatus status;
  final HSSpot topSpot;
  final List<HSSpot> spots;

  @override
  List<Object> get props => [
        status,
        topSpot,
        spots,
      ];

  HSTagsExploreState copyWith({
    HSTagsExploreStatus? status,
    HSSpot? topSpot,
    List<HSSpot>? spots,
  }) {
    return HSTagsExploreState(
      status: status ?? this.status,
      topSpot: topSpot ?? this.topSpot,
      spots: spots ?? this.spots,
    );
  }
}
