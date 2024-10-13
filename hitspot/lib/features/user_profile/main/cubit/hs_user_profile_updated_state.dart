part of 'hs_user_profile_updated_cubit.dart';

enum HSUserProfileUpdatedStatus { loading, refteshing, ready, error, follow }

final class HsUserProfileUpdatedState extends Equatable {
  const HsUserProfileUpdatedState({
    this.followersCount = 0,
    this.user = const HSUser(),
    this.followingCount = 0,
    this.spotsCount = 0,
    this.status = HSUserProfileUpdatedStatus.loading,
    this.followers = const [],
    this.following = const [],
    this.spots = const [],
    this.boards = const [],
    this.isFollowed = false,
  });

  final int followersCount, followingCount, spotsCount;
  final HSUserProfileUpdatedStatus status;
  final List<String> followers, following;
  final List<HSSpot> spots;
  final List<HSBoard> boards;
  final HSUser user;
  final bool isFollowed;

  bool get isLoading => status == HSUserProfileUpdatedStatus.loading;
  bool get isRefreshing => status == HSUserProfileUpdatedStatus.refteshing;
  bool get isReady => status == HSUserProfileUpdatedStatus.ready;
  bool get isError => status == HSUserProfileUpdatedStatus.error;
  bool get isFollow => status == HSUserProfileUpdatedStatus.follow;

  @override
  List<Object> get props => [
        followersCount,
        followingCount,
        spotsCount,
        status,
        followers,
        following,
        spots,
        boards,
        user,
        isFollowed
      ];

  HsUserProfileUpdatedState copyWith({
    int? followersCount,
    int? followingCount,
    int? spotsCount,
    HSUserProfileUpdatedStatus? status,
    List<String>? followers,
    List<String>? following,
    List<HSSpot>? spots,
    List<HSBoard>? boards,
    HSUser? user,
    bool? isFollowed,
  }) {
    return HsUserProfileUpdatedState(
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      spotsCount: spotsCount ?? this.spotsCount,
      status: status ?? this.status,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      spots: spots ?? this.spots,
      boards: boards ?? this.boards,
      user: user ?? this.user,
      isFollowed: isFollowed ?? this.isFollowed,
    );
  }
}
