part of 'hs_user_profile_cubit.dart';

enum HSUserProfileStatus {
  initial,
  loading,
  following,
  loaded,
  error,
  loadingMoreSpots,
  loadingMoreBoards
}

final class HSUserProfileState extends Equatable {
  const HSUserProfileState({
    this.status = HSUserProfileStatus.initial,
    this.user,
    this.isFollowed,
    this.spots = const [],
    this.boards = const [],
    this.followersCount = 0,
    this.spotsCount = 0,
    this.followingCount = 0,
    this.trips = const [],
    this.followersCount = 0,
    this.spotsCount = 0,
    this.followingCount = 0,
  });

  final HSUserProfileStatus status;
  final HSUser? user;
  final bool? isFollowed;
  final List<HSSpot> spots;
  final List<HSBoard> boards;
  final int followersCount, followingCount, spotsCount;
  final List<dynamic> trips;
  final int followersCount, followingCount, spotsCount;

  @override
  List<Object?> get props => [
        status,
        user,
        isFollowed,
        spots,
        boards,
        followersCount,
        followingCount,
        spotsCount,
        trips
      ];

  HSUserProfileState copyWith({
    HSUserProfileStatus? status,
    HSUser? user,
    bool? isFollowed,
    List<HSSpot>? spots,
    List<HSBoard>? boards,
    int? followersCount,
    int? followingCount,
    int? spotsCount,
    List<dynamic>? trips,
    int? followersCount,
    int? followingCount,
    int? spotsCount,
  }) {
    return HSUserProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      isFollowed: isFollowed ?? this.isFollowed,
      spots: spots ?? this.spots,
      boards: boards ?? this.boards,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      spotsCount: spotsCount ?? this.spotsCount,
      trips: trips ?? this.trips,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      spotsCount: spotsCount ?? this.spotsCount,
    );
  }
}
