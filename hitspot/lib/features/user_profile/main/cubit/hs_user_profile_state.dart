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
    this.trips = const [],
  });

  final HSUserProfileStatus status;
  final HSUser? user;
  final bool? isFollowed;
  final List<HSSpot> spots;
  final List<HSBoard> boards;
  final List<dynamic> trips;

  @override
  List<Object?> get props => [status, user, isFollowed, spots, boards, trips];

  HSUserProfileState copyWith({
    HSUserProfileStatus? status,
    HSUser? user,
    bool? isFollowed,
    List<HSSpot>? spots,
    List<HSBoard>? boards,
    List<dynamic>? trips,
  }) {
    return HSUserProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      isFollowed: isFollowed ?? this.isFollowed,
      spots: spots ?? this.spots,
      boards: boards ?? this.boards,
      trips: trips ?? this.trips,
    );
  }
}
