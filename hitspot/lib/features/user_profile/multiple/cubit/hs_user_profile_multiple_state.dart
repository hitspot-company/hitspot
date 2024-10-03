part of 'hs_user_profile_multiple_cubit.dart';

enum HSUserProfileMultipleStatus { initial, loading, loaded, error }

enum HSUserProfileMultipleType { followers, following, likes, collaborators }

final class HsUserProfileMultipleState extends Equatable {
  const HsUserProfileMultipleState({
    this.status = HSUserProfileMultipleStatus.initial,
    this.users = const [],
    this.followers = const [],
    this.following = const [],
    this.userSpot = const Pair(null, null),
  });

  final HSUserProfileMultipleStatus status;
  final List<HSUser> users, followers, following;
  final Pair<HSUser?, HSSpot?> userSpot;

  @override
  List<Object> get props => [status, users, followers, following, userSpot];

  HsUserProfileMultipleState copyWith({
    HSUserProfileMultipleStatus? status,
    List<HSUser>? users,
    List<HSUser>? followers,
    List<HSUser>? following,
    Pair<HSUser?, HSSpot?>? userSpot,
  }) {
    return HsUserProfileMultipleState(
      status: status ?? this.status,
      users: users ?? this.users,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      userSpot: userSpot ?? this.userSpot,
    );
  }
}
