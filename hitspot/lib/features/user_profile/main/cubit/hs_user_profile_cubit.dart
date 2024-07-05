import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';

part 'hs_user_profile_state.dart';

class HSUserProfileCubit extends Cubit<HSUserProfileState> {
  HSUserProfileCubit(this.userID) : super(const HSUserProfileState()) {
    _init();
  }

  late final bool isOwnProfile;
  final String userID;
  final _databaseRepository = app.databaseRepository;

  Future<void> refresh() async {
    emit(state.copyWith(status: HSUserProfileStatus.loading));
    await Future.delayed(const Duration(seconds: 1));
    await _fetchUserData();
  }

  Future<void> _init() async {
    emit(state.copyWith(status: HSUserProfileStatus.loading));
    if (userID == currentUser.uid) {
      isOwnProfile = true;
    } else {
      isOwnProfile = false;
    }
    await _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = await app.databaseRepository.userRead(userID: userID);
      final List<HSSpot> userSpots =
          await _databaseRepository.spotfetchUserSpots(user: user);
      final List<HSBoard> userBoards =
          await _databaseRepository.boardFetchUserBoards(user: user);
      HSDebugLogger.logSuccess("Fetched user boards: ${userBoards.length}");
      final bool? isFollowed = await app.databaseRepository
          .userIsUserFollowed(followerID: currentUser.uid, followedID: userID);
      HSDebugLogger.logSuccess("Fetched following: $isFollowed");
      emit(state.copyWith(
        status: HSUserProfileStatus.loaded,
        user: user,
        spots: userSpots,
        boards: userBoards,
        isFollowed: isFollowed ?? false,
      ));
    } catch (_) {
      HSDebugLogger.logError(_.toString());
    }
  }

  Future<void> followUser() async {
    HSDebugLogger.logInfo("Initial User Data: ${state.user.toString()}");
    try {
      emit(state.copyWith(status: HSUserProfileStatus.following));
      await app.databaseRepository.userFollow(
          isFollowed: state.isFollowed!,
          followerID: currentUser.uid!,
          followedID: userID);
      late final int updatedFollowers;
      if (!state.isFollowed!) {
        updatedFollowers = state.user!.followers! + 1;
      } else {
        updatedFollowers = state.user!.followers! - 1;
      }
      HSDebugLogger.logInfo(state.user.toString());
      emit(state.copyWith(
          status: HSUserProfileStatus.loaded,
          isFollowed: !state.isFollowed!,
          user: state.user?.copyWith(followers: updatedFollowers)));
    } catch (_) {
      HSDebugLogger.logError(_.toString());
    }
  }
}
