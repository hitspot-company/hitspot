part of 'hs_user_profile_bloc.dart';

sealed class HSUserProfileEvent extends Equatable {
  const HSUserProfileEvent();

  @override
  List<Object> get props => [];
}

final class HSUserProfileInitialEvent extends HSUserProfileEvent {}

final class HSUserProfileFollowUnfollowUserEvent extends HSUserProfileEvent {}
