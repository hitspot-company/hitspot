part of 'hs_single_spot_cubit.dart';

enum HSSingleSpotStatus { loading, loaded, liking, saving, error }

final class HsSingleSpotState extends Equatable {
  const HsSingleSpotState({
    this.status = HSSingleSpotStatus.loading,
    this.spot = const HSSpot(),
    this.isSpotLiked = false,
    this.isSpotSaved = false,
  });

  final HSSingleSpotStatus status;
  final HSSpot spot;
  final bool isSpotLiked, isSpotSaved;

  @override
  List<Object> get props => [status, spot, isSpotLiked, isSpotSaved];

  HsSingleSpotState copyWith({
    HSSingleSpotStatus? status,
    HSSpot? spot,
    bool? isSpotLiked,
    bool? isSpotSaved,
  }) {
    return HsSingleSpotState(
      status: status ?? this.status,
      spot: spot ?? this.spot,
      isSpotLiked: isSpotLiked ?? this.isSpotLiked,
      isSpotSaved: isSpotSaved ?? this.isSpotSaved,
    );
  }
}
