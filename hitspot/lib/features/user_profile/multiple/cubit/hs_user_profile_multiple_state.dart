part of 'hs_user_profile_multiple_cubit.dart';

enum HSUserProfileMultipleStatus { initial, loading, loaded, error }

enum HSUserProfileMultipleType { follows, likes, collaborators }

final class HsUserProfileMultipleState extends Equatable {
  const HsUserProfileMultipleState({
    this.status = HSUserProfileMultipleStatus.initial,
    this.users = const [],
    this.followers = const [],
    this.following = const [],
  });

  final HSUserProfileMultipleStatus status;
  final List<HSUser> users, followers, following;

  @override
  List<Object> get props => [status, users, followers, following];

  HsUserProfileMultipleState copyWith({
    HSUserProfileMultipleStatus? status,
    List<HSUser>? users,
    List<HSUser>? followers,
    List<HSUser>? following,
  }) {
    return HsUserProfileMultipleState(
      status: status ?? this.status,
      users: users ?? this.users,
      followers: followers ?? this.followers,
      following: following ?? this.following,
    );
  }
}
