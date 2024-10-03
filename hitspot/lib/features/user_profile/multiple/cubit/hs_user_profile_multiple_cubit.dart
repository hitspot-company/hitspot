import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';

part 'hs_user_profile_multiple_state.dart';

class HsUserProfileMultipleCubit extends Cubit<HsUserProfileMultipleState> {
  HsUserProfileMultipleCubit(this.type, this.userID, this.spotID, this.boardID)
      : super(const HsUserProfileMultipleState());

  final HSUserProfileMultipleType type;
  final String? userID;
  final String? spotID;
  final String? boardID;
  final _databaseRepository = app.databaseRepository;

  void fetchUsers() async {
    emit(state.copyWith(status: HSUserProfileMultipleStatus.loading));
    try {
      final users = <HSUser>[];
      switch (type) {
        case HSUserProfileMultipleType.follows:
          await _fetchFollowers();
          await _fetchFollowed();
          break;
        case HSUserProfileMultipleType.likes:
          await _fetchLikers();
          break;
        case HSUserProfileMultipleType.collaborators:
          HSDebugLogger.logInfo("Not implemented yet");
          break;
      }
      emit(state.copyWith(
          status: HSUserProfileMultipleStatus.loaded, users: users));
    } catch (e) {
      emit(state.copyWith(status: HSUserProfileMultipleStatus.error));
    }
  }

  Future<void> _fetchFollowers() async {
    emit(state.copyWith(status: HSUserProfileMultipleStatus.loading));
    try {
      final batchOffset = state.followers.length;
      final followers = await _databaseRepository.userFetchFollowers(
          userID: userID, batchOffset: batchOffset);
      emit(state.copyWith(
          status: HSUserProfileMultipleStatus.loaded, followers: followers));
    } catch (e) {
      emit(state.copyWith(status: HSUserProfileMultipleStatus.error));
    }
  }

  Future<void> _fetchFollowed() async {
    emit(state.copyWith(status: HSUserProfileMultipleStatus.loading));
    try {
      final batchOffset = state.following.length;
      final following = await _databaseRepository.userFetchFollowed(
          userID: userID, batchOffset: batchOffset);
      emit(state.copyWith(
          status: HSUserProfileMultipleStatus.loaded, following: following));
    } catch (e) {
      emit(state.copyWith(status: HSUserProfileMultipleStatus.error));
    }
  }

  Future<void> _fetchLikers() async {
    emit(state.copyWith(status: HSUserProfileMultipleStatus.loading));
    try {
      final batchOffset = state.users.length;
      final users = await _databaseRepository.userFetchSpotLikers(
          spotID: spotID, batchOffset: batchOffset);
      emit(state.copyWith(
          status: HSUserProfileMultipleStatus.loaded, users: users));
    } catch (e) {
      emit(state.copyWith(status: HSUserProfileMultipleStatus.error));
    }
  }
}
