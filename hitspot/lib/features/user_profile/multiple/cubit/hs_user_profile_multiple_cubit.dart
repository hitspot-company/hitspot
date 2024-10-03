import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:pair/pair.dart';

part 'hs_user_profile_multiple_state.dart';

class HsUserProfileMultipleCubit extends Cubit<HsUserProfileMultipleState> {
  HsUserProfileMultipleCubit(this.type, this.userID, this.spotID, this.boardID)
      : super(const HsUserProfileMultipleState()) {
    _init();
  }

  final HSUserProfileMultipleType type;
  final String? userID;
  final String? spotID;
  final String? boardID;
  final _databaseRepository = app.databaseRepository;

  // Pagination
  late final HSHitsPage hitsPage;
  PagingController<int, dynamic> get pagingController =>
      hitsPage.pagingController;

  HSHitsPage get _hitsPage {
    switch (type) {
      case HSUserProfileMultipleType.followers:
        return HSHitsPage(
            pageSize: 20, fetch: _fetchFollowers, type: HSHitsPageType.users);
      case HSUserProfileMultipleType.following:
        return HSHitsPage(
            pageSize: 20, fetch: _fetchFollowed, type: HSHitsPageType.users);
      case HSUserProfileMultipleType.likes:
        return HSHitsPage(
            pageSize: 10, fetch: _fetchLikers, type: HSHitsPageType.spots);
      default:
        emit(state.copyWith(status: HSUserProfileMultipleStatus.error));
        HSDebugLogger.logInfo("Not implemented yet");
        return HSHitsPage(
            pageSize: 10,
            fetch: (size, offset) async => [],
            type: HSHitsPageType.users);
    }
  }

  String get pageTitle {
    switch (type) {
      case HSUserProfileMultipleType.followers:
        return "Followers";
      case HSUserProfileMultipleType.following:
        return "Following";
      case HSUserProfileMultipleType.likes:
        return "Likes";
      case HSUserProfileMultipleType.collaborators:
        return "Collaborators";
    }
  }

  void _init() async {
    emit(state.copyWith(status: HSUserProfileMultipleStatus.loading));
    try {
      // await _fetchSubject();
      hitsPage = _hitsPage;
      emit(state.copyWith(status: HSUserProfileMultipleStatus.loaded));
    } catch (e) {
      emit(state.copyWith(status: HSUserProfileMultipleStatus.error));
    }
  }

  // Future<void> _initFetch() async {
  //   emit(state.copyWith(status: HSUserProfileMultipleStatus.loading));
  //   try {
  //     final users = <HSUser>[];
  //     switch (type) {
  //       case HSUserProfileMultipleType.followers ||
  //             HSUserProfileMultipleType.following:
  //         await _fetchFollowers();
  //         await _fetchFollowed();
  //         break;
  //       case HSUserProfileMultipleType.likes:
  //         await _fetchLikers();
  //         break;
  //       case HSUserProfileMultipleType.collaborators:
  //         HSDebugLogger.logInfo("Not implemented yet");
  //         break;
  //     }
  //     emit(state.copyWith(
  //         status: HSUserProfileMultipleStatus.loaded, users: users));
  //   } catch (e) {
  //     emit(state.copyWith(status: HSUserProfileMultipleStatus.error));
  //   }
  // }

  Future<List<HSUser>> _fetchFollowers(int size, int offset) async {
    try {
      final followers = await _databaseRepository.userFetchFollowers(
          userID: userID, batchOffset: offset, batchSize: size);
      return (followers);
    } catch (e) {
      emit(state.copyWith(status: HSUserProfileMultipleStatus.error));
      HSDebugLogger.logError("Error fetching followers: $e");
      rethrow;
    }
  }

  Future<List<HSUser>> _fetchFollowed(int size, int offset) async {
    try {
      final following = await _databaseRepository.userFetchFollowed(
          userID: userID, batchOffset: offset, batchSize: size);
      return following;
    } catch (e) {
      emit(state.copyWith(status: HSUserProfileMultipleStatus.error));
      HSDebugLogger.logError("Error fetching following: $e");
      rethrow;
    }
  }

  Future<List<HSUser>> _fetchLikers(int size, int offset) async {
    try {
      final users = await _databaseRepository.userFetchSpotLikers(
          spotID: spotID, batchOffset: offset, batchSize: size);
      return users;
    } catch (e) {
      emit(state.copyWith(status: HSUserProfileMultipleStatus.error));
      HSDebugLogger.logError("Error fetching likers: $e");
      rethrow;
    }
  }

  // Future<void> _fetchSubject() async {
  //   try {
  //     if (type == HSUserProfileMultipleType.followers ||
  //         type == HSUserProfileMultipleType.following) {
  //       final user = await _databaseRepository.userRead(userID: userID);
  //       emit(state.copyWith(userSpot: Pair(user, null)));
  //     } else if (type == HSUserProfileMultipleType.likes) {
  //       final spot = await _databaseRepository.spotRead(spotID: spotID);
  //       emit(state.copyWith(userSpot: Pair(null, spot)));
  //     } else {
  //       emit(state.copyWith(userSpot: const Pair(null, null)));
  //       HSDebugLogger.logInfo("Not implemented yet");
  //     }
  //   } catch (e) {
  //     emit(state.copyWith(status: HSUserProfileMultipleStatus.error));
  //     HSDebugLogger.logInfo("Error fetching subject: $e");
  //   }
  // }

  @override
  Future<void> close() {
    hitsPage.dispose();
    return super.close();
  }
}
