part of 'hs_single_spot_cubit.dart';

enum HSSingleSpotStatus {
  loading,
  loaded,
  liking,
  saving,
  addingToBoard,
  deleting,
  error
}

final class HSSingleSpotState extends Equatable {
  const HSSingleSpotState({
    this.status = HSSingleSpotStatus.loading,
    this.spot = const HSSpot(),
    this.isSpotLiked = false,
    this.isSpotSaved = false,
    this.isAuthor = false,
    this.tags = const [],
  });

  final HSSingleSpotStatus status;
  final HSSpot spot;
  final bool isSpotLiked, isSpotSaved, isAuthor;
  final List<HSTag> tags;

  @override
  List<Object> get props =>
      [status, spot, isSpotLiked, isSpotSaved, isAuthor, tags];

  HSSingleSpotState copyWith({
    HSSingleSpotStatus? status,
    HSSpot? spot,
    bool? isSpotLiked,
    bool? isSpotSaved,
    bool? isAuthor,
    List<HSTag>? tags,
  }) {
    return HSSingleSpotState(
      status: status ?? this.status,
      spot: spot ?? this.spot,
      isSpotLiked: isSpotLiked ?? this.isSpotLiked,
      isSpotSaved: isSpotSaved ?? this.isSpotSaved,
      isAuthor: isAuthor ?? this.isAuthor,
      tags: tags ?? this.tags,
    );
  }
}
