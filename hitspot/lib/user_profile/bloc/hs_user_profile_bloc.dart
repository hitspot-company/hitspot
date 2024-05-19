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
      await _getUserData(event, emit);
      isOwnProfile = userData?.uid == currentUser.uid;
    });
    on<HSUserProfileFollowUnfollowUserEvent>(followUnfollowUser);
  }

  late final bool isOwnProfile;
  final String userID;
  final HSDatabaseRepository databaseRepository;
  late final HSUser? userData;
  final ScrollController scrollController = ScrollController();

  bool isUserFollowed() {
    if (state is HSUserProfileReady) {
      final HSUserProfileReady readyState = state as HSUserProfileReady;
      return readyState.user?.followers?.contains(currentUser.uid) ?? false;
    }
    return (false);
  }

  Future<void> followUnfollowUser(event, emit) async {
    late final bool followed;
    try {
      if (state is HSUserProfileReady) {
        final HSUserProfileReady readyState = state as HSUserProfileReady;
        if (isUserFollowed()) {
          await databaseRepository.unfollowUser(currentUser, readyState.user!);
          followed = false;
        } else {
          await databaseRepository.followUser(currentUser, readyState.user!);
          followed = true;
        }
        emitChanged(event, emit, followed: followed, user: readyState.user!);
        HSDebugLogger.logSuccess(followed ? "Followed" : "Unfollowed");
      }
    } on DatabaseConnectionFailure catch (_) {
      HSDebugLogger.logWarning(_.message);
    } catch (_) {
      HSDebugLogger.logWarning(_.toString());
    }
  }

  void emitChanged(event, emit,
      {required bool followed, required HSUser user}) {
    if (followed) {
      if (user.followers == null) {
        emit(HSUserProfileReady(user.copyWith(followers: [currentUser.uid])));
      } else {
        user.followers!.add(currentUser.uid);
        emit(HSUserProfileReady(user));
      }
    } else {
      user.followers!.remove(currentUser.uid);
      emit(HSUserProfileReady(user));
    }
  }

  Future<void> _getUserData(event, emit) async {
    emit(HSUserProfileInitialLoading());
    try {
      userData = await databaseRepository.getUserFromDatabase(userID);
      emit(HSUserProfileReady(userData));
    } on DatabaseConnectionFailure catch (e) {
      emit(HSUserProfileError(e.message));
    } catch (e) {
      emit(const HSUserProfileError("An unknown error occured"));
    }
  }
}
