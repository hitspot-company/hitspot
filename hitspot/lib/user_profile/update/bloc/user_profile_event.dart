part of 'user_profile_bloc.dart';

sealed class UserProfileEvent extends Equatable {
  const UserProfileEvent();

  @override
  List<Object?> get props => [];
}

final class UserProfileLoad extends UserProfileEvent {
  const UserProfileLoad(this.userID);
  final String userID;

  @override
  List<Object> get props => [userID];
}

final class UserProfileFollowUser extends UserProfileEvent {
  // ignore: non_constant_identifier_names
  const UserProfileFollowUser(this.user);

  final HSUser user;

  @override
  List<Object?> get props => [user, user.followers, user.following];
}
