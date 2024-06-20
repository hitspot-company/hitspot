part of 'hs_single_spot_cubit.dart';

enum HSSingleSpotStatus { loading, loaded, error }

final class HsSingleSpotState extends Equatable {
  const HsSingleSpotState({
    this.status = HSSingleSpotStatus.loading,
    this.spot = const HSSpot(),
  });

  final HSSingleSpotStatus status;
  final HSSpot spot;

  @override
  List<Object> get props => [status, spot];

  HsSingleSpotState copyWith({
    HSSingleSpotStatus? status,
    HSSpot? spot,
  }) {
    return HsSingleSpotState(
      status: status ?? this.status,
      spot: spot ?? this.spot,
    );
  }
}
