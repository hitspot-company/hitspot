import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';

part 'hs_user_profile_event.dart';
part 'hs_user_profile_state.dart';

class HSUserProfileBloc extends Bloc<HSUserProfileEvent, HSUserProfileState> {
  HSUserProfileBloc({
    required this.databaseRepository,
    required this.userID,
  }) : super(HSUserProfileInitialLoading()) {
    on<HSUserProfileInitialEvent>((event, emit) async {
      await Future.delayed(const Duration(milliseconds: 300));
      await _fetchInitial(event, emit);
      isOwnProfile = userID == currentUser.uid;
    });
    on<HSUserProfileFollowUnfollowUserEvent>(followUnfollowUser);
    on<HSUserProfileRequestUpdateEvent>(_update);
  }

  late final bool isOwnProfile;
  final String userID;
  final HSDatabaseRepsitory databaseRepository;
  final ScrollController scrollController = ScrollController();

  Future<void> _update(event, emit) async {
    try {
      await _fetchInitial(event, emit);
    } catch (_) {
      HSDebugLogger.logError(_.toString());
      emit(const HSUserProfileError("An unknown error occured"));
    }
  }

  bool isUserFollowed() {
    if (state is HSUserProfileReady) {
      final HSUserProfileReady readyState = state as HSUserProfileReady;
      // return readyState.user?.followers?.contains(currentUser.uid) ?? false;
      return false; // TODO: Change
    }
    return (false);
  }

  Future<void> followUnfollowUser(event, emit) async {
    // late final bool followed;
    // try {
    //   if (state is HSUserProfileReady) {
    //     final HSUserProfileReady readyState = state as HSUserProfileReady;
    //     emit(HSUserProfileUpdate(readyState.user, readyState.boards));
    //     if (isUserFollowed()) {
    //       await databaseRepository.userUnfollow(currentUser, readyState.user!);
    //       followed = false;
    //     } else {
    //       await databaseRepository.userFollow(currentUser, readyState.user!);
    //       followed = true;
    //     }
    //     emitChanged(event, emit, followed: followed, user: readyState.user!);
    //     HSDebugLogger.logSuccess(followed ? "Followed" : "Unfollowed");
    //   }
    // } on DatabaseConnectionFailure catch (_) {
    //   HSDebugLogger.logWarning(_.message);
    // } catch (_) {
    //   HSDebugLogger.logWarning(_.toString());
    // }
  }

  void emitChanged(event, emit,
      {required bool followed, required HSUser user}) {
    // if (followed) {
    //   if (user.followers == null) {
    //     emit(HSUserProfileReady(user.copyWith(followers: [currentUser.uid])));
    //   } else {
    //     user.followers!.add(currentUser.uid);
    //     emit(HSUserProfileReady(user));
    //   }
    // } else {
    //   user.followers!.remove(currentUser.uid);
    //   emit(HSUserProfileReady(user));
    // }
  }

  Future<void> _fetchInitial(event, emit) async {
    emit(HSUserProfileInitialLoading());
    try {
      final HSUser userData = await databaseRepository.userRead(userID: userID);
      // final List<HSBoard> boards =
      //     await databaseRepository.boardGetUserBoards(user: userData);
      emit(HSUserProfileReady(userData));
    } on HSUserException catch (e) {
      emit(HSUserProfileError(e.message));
      // navi.toError("Error", e.message);
    } catch (e) {
      emit(const HSUserProfileError("An unknown error occured"));
      // navi.toError("404: Not found",
      //     "The user account does not exist or has been removed.");
    }
  }
}
