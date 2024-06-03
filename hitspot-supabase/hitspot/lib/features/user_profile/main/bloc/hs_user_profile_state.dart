part of 'hs_user_profile_bloc.dart';

sealed class HSUserProfileState extends Equatable {
  const HSUserProfileState();

  @override
  List<Object> get props => [];
}

final class HSUserProfileInitial extends HSUserProfileState {}

final class HSUserProfileInitialLoading extends HSUserProfileState {}

final class HSUserProfileReady extends HSUserProfileState {
  const HSUserProfileReady(
    this.user,
    // [this.boards]
  );
  final HSUser? user;
  // final List<HSBoard>? boards;
}

final class HSUserProfileUpdate extends HSUserProfileReady {
  const HSUserProfileUpdate(
    super.user,
    // super.boards
  );
}

final class HSUserProfileError extends HSUserProfileState {
  const HSUserProfileError(this.error);
  final String error;

  @override
  List<Object> get props => [];
}
