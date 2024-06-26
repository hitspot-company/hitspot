part of 'hs_user_profile_cubit.dart';

enum HSUserProfileStatus { initial, loading, following, loaded, error }

final class HSUserProfileState extends Equatable {
  const HSUserProfileState({
    this.status = HSUserProfileStatus.initial,
    this.user,
    this.isFollowed,
    this.spots = const [],
  });

  final HSUserProfileStatus status;
  final HSUser? user;
  final bool? isFollowed;
  final List<HSSpot> spots;

  @override
  List<Object?> get props => [status, user, isFollowed, spots];

  HSUserProfileState copyWith({
    HSUserProfileStatus? status,
    HSUser? user,
    bool? isFollowed,
    List<HSSpot>? spots,
  }) {
    return HSUserProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      isFollowed: isFollowed ?? this.isFollowed,
      spots: spots ?? this.spots,
    );
  }
}
