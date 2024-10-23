import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';

part 'hs_user_profile_updated_state.dart';

class HsUserProfileUpdatedCubit extends Cubit<HsUserProfileUpdatedState> {
  HsUserProfileUpdatedCubit(this.userID)
      : super(const HsUserProfileUpdatedState()) {
    _init();
  }

  final String userID;
  final _databaseRepository = app.databaseRepository;
  bool get isCurrentUser => userID == currentUser.uid;

  late final HSSpotsPage spotsPage;
  late final HSBoardsPage boardsPage;

  void _init() async {
    try {
      emit(state.copyWith(status: HSUserProfileUpdatedStatus.loading));
      final user = await _databaseRepository.userRead(userID: userID);
      spotsPage = HSSpotsPage(fetch: _fetchSpots, pageSize: 10);
      boardsPage = HSBoardsPage(fetch: _fetchBoards, pageSize: 10);
      final isFollowed = await _databaseRepository.userIsUserFollowed(
          followedID: userID, followerID: currentUser.uid);
      emit(state.copyWith(
        user: user,
        followersCount: user.followers,
        followingCount: user.following,
        isFollowed: isFollowed,
        status: HSUserProfileUpdatedStatus.ready,
      ));
    } catch (e) {
      emit(state.copyWith(status: HSUserProfileUpdatedStatus.error));
      HSDebugLogger.logError('Failed to load user profile $e');
    }
  }

  Future<List<HSSpot>> _fetchSpots(int batchSize, int batchOffset) async {
    try {
      final batch = await _databaseRepository.spotFetchUserSpots(
          userID: userID, batchSize: batchSize, batchOffset: batchOffset);
      return batch;
    } catch (e) {
      HSDebugLogger.logError("[!] Failed to fetch spots: $e");
    }
    return [];
  }

  Future<List<HSBoard>> _fetchBoards(int batchSize, int batchOffset) async {
    try {
      final batch = await _databaseRepository.boardFetchUserBoards(
          userID: userID, batchOffset: batchOffset, batchSize: batchSize);
      return batch;
    } catch (e) {
      HSDebugLogger.logError("[!] Failed to fetch spots: $e");
    }
    return [];
  }

  Future<void> followUnfollow() async {
    try {
      emit(state.copyWith(status: HSUserProfileUpdatedStatus.follow));
      await _databaseRepository.userFollow(
          followedID: userID,
          followerID: currentUser.uid,
          isFollowed: state.isFollowed);
      emit(state.copyWith(
        followersCount: state.followersCount + (state.isFollowed ? -1 : 1),
        isFollowed: !state.isFollowed,
        status: HSUserProfileUpdatedStatus.ready,
      ));
    } catch (e) {
      emit(state.copyWith(status: HSUserProfileUpdatedStatus.error));
      HSDebugLogger.logError('Failed to follow/unfollow user $e');
    }
  }

  @override
  Future<void> close() {
    spotsPage.dispose();
    boardsPage.dispose();
    return super.close();
  }
}
