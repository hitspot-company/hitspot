part of 'hs_single_spot_cubit.dart';

enum HSSingleSpotStatus { loading, loaded, liking, saving, deleting, error }

final class HSSingleSpotState extends Equatable {
  const HSSingleSpotState({
    this.status = HSSingleSpotStatus.loading,
    this.spot = const HSSpot(),
    this.isSpotLiked = false,
    this.isSpotSaved = false,
    this.isAuthor = false,
  });

  final HSSingleSpotStatus status;
  final HSSpot spot;
  final bool isSpotLiked, isSpotSaved, isAuthor;

  @override
  List<Object> get props => [status, spot, isSpotLiked, isSpotSaved, isAuthor];

  HSSingleSpotState copyWith({
    HSSingleSpotStatus? status,
    HSSpot? spot,
    bool? isSpotLiked,
    bool? isSpotSaved,
    bool? isAuthor,
  }) {
    return HSSingleSpotState(
      status: status ?? this.status,
      spot: spot ?? this.spot,
      isSpotLiked: isSpotLiked ?? this.isSpotLiked,
      isSpotSaved: isSpotSaved ?? this.isSpotSaved,
      isAuthor: isAuthor ?? this.isAuthor,
    );
  }
}
