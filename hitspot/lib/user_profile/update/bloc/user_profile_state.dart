part of 'user_profile_bloc.dart';

sealed class UserProfileState extends Equatable {
  const UserProfileState();

  @override
  List<Object?> get props => [];
}

final class UserProfileInitial extends UserProfileState {}

final class UserProfileLoading extends UserProfileState {}

final class UserProfileError extends UserProfileState {
  const UserProfileError(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}

final class UserProfileLoaded extends UserProfileState {
  const UserProfileLoaded(this.user);
  final HSUser user;

  @override
  List<Object?> get props => [user, user.followers];
}

final class UserProfileUpdating extends UserProfileState {
  const UserProfileUpdating(this.user);
  final HSUser user;

  @override
  List<Object?> get props => [user, user.followers];
}
