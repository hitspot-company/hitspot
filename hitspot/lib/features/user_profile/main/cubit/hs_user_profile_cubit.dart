import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
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
  final _spotsScrollController = ScrollController();
  final _boardsScrollController = ScrollController();

  ScrollController get spotsScrollController => _spotsScrollController;
  ScrollController get boardsScrollController => _boardsScrollController;

  void _onSpotsScroll() {
    if (_spotsScrollController.position.pixels >=
            _spotsScrollController.position.maxScrollExtent - 200 &&
        state.status != HSUserProfileStatus.loadingMoreSpots) {
      _loadMoreSpots();
    }
  }

  void _onBoardsScroll() {
    if (_boardsScrollController.position.pixels >=
            _boardsScrollController.position.maxScrollExtent - 200 &&
        state.status != HSUserProfileStatus.loadingMoreBoards) {
      _loadMoreBoards();
    }
  }

  Future<void> _loadMoreSpots() async {
    HSDebugLogger.logInfo("Fetching more spots...");
    emit(state.copyWith(status: HSUserProfileStatus.loadingMoreSpots));

    try {
      final newSpots =
          await _databaseRepository.spotFetchUserSpots(user: state.user!);

      if (newSpots.isEmpty) {
        emit(state.copyWith(
          status: HSUserProfileStatus.loaded,
          // hasReachedMaxSpots: true,
        ));
      } else {
        emit(state.copyWith(
          status: HSUserProfileStatus.loaded,
          spots: List.of(state.spots)..addAll(newSpots),
        ));
      }
    } catch (e) {
      HSDebugLogger.logError("Error loading more spots: $e");
      emit(state.copyWith(status: HSUserProfileStatus.error));
    }
  }

  Future<void> _loadMoreBoards() async {
    HSDebugLogger.logInfo("Fetching more boards...");
    emit(state.copyWith(status: HSUserProfileStatus.loadingMoreBoards));

    try {
      final newBoards = await _databaseRepository.boardFetchUserBoards(
        user: state.user!,
        // batchOffset: state.boards.length - 1,
        // batchSize: 10,
      );

      if (newBoards.isEmpty) {
        emit(state.copyWith(
          status: HSUserProfileStatus.loaded,
          // hasReachedMaxBoards: true,
        ));
      } else {
        emit(state.copyWith(
          status: HSUserProfileStatus.loaded,
          boards: List.of(state.boards)..addAll(newBoards),
        ));
      }
    } catch (e) {
      HSDebugLogger.logError("Error loading more boards: $e");
      emit(state.copyWith(status: HSUserProfileStatus.error));
    }
  }

  Future<void> refresh() async {
    emit(state.copyWith(status: HSUserProfileStatus.loading));
    await _fetchUserData();
  }

  Future<void> _init() async {
    try {
      _spotsScrollController.addListener(_onSpotsScroll);
      _boardsScrollController.addListener(_onBoardsScroll);
      emit(state.copyWith(status: HSUserProfileStatus.loading));
      if (userID == currentUser.uid) {
        isOwnProfile = true;
      } else {
        isOwnProfile = false;
      }
      await _fetchUserData(useCache: true);
    } catch (e) {
      HSDebugLogger.logError("Error initializing user profile: $e");
      navi.toError(
        title: "Error",
        message: "An error occurred while loading the user profile.",
      );
    }
  }

  Future<void> _fetchUserData({bool useCache = false}) async {
    try {
      final user = await app.databaseRepository
          .userRead(userID: userID, useCache: useCache);
      final List<HSSpot> userSpots = await _databaseRepository
          .spotFetchUserSpots(user: user, useCache: useCache);
      final List<HSBoard> userBoards = await _databaseRepository
          .boardFetchUserBoards(user: user, useCache: useCache);
      final bool? isFollowed = await app.databaseRepository
          .userIsUserFollowed(followerID: currentUser.uid, followedID: userID);
      emit(state.copyWith(
        status: HSUserProfileStatus.loaded,
        user: user,
        followersCount: user.followers,
        followingCount: user.following,
        spotsCount: user.spots,
        spots: userSpots,
        boards: userBoards,
        isFollowed: isFollowed ?? false,
      ));
    } catch (_) {
      HSDebugLogger.logError(_.toString());
      rethrow;
    }
  }

  void clearData() {
    emit(const HSUserProfileState());
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
        updatedFollowers = state.followersCount + 1;
      } else {
        updatedFollowers = state.followersCount - 1;
      }
      HSDebugLogger.logInfo(state.user.toString());
      emit(state.copyWith(
        status: HSUserProfileStatus.loaded,
        isFollowed: !state.isFollowed!,
        followersCount: updatedFollowers,
      ));
    } catch (_) {
      HSDebugLogger.logError(_.toString());
    }
  }

  @override
  Future<void> close() {
    _spotsScrollController.removeListener(_onSpotsScroll);
    _boardsScrollController.removeListener(_onBoardsScroll);
    _spotsScrollController.dispose();
    _boardsScrollController.dispose();
    return super.close();
  }
}
