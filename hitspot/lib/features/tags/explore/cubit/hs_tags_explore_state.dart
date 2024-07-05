part of 'hs_tags_explore_cubit.dart';

enum HSTagsExploreStatus { initial, loading, loaded, error }

final class HsTagsExploreState extends Equatable {
  const HsTagsExploreState({
    this.status = HSTagsExploreStatus.initial,
    this.topSpot = const HSSpot(),
  });

  final HSTagsExploreStatus status;
  final HSSpot topSpot;

  @override
  List<Object> get props => [
        status,
        topSpot,
      ];

  HsTagsExploreState copyWith({
    HSTagsExploreStatus? status,
    HSSpot? topSpot,
  }) {
    return HsTagsExploreState(
      status: status ?? this.status,
      topSpot: topSpot ?? this.topSpot,
    );
  }
}
