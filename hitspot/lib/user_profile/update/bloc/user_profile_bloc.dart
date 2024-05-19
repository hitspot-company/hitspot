import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';

part 'user_profile_event.dart';
part 'user_profile_state.dart';

class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  UserProfileBloc(this._databaseRepository, this.userID)
      : super(UserProfileLoading()) {
    on<UserProfileLoad>(_fetchUserData);
    on<UserProfileFollowUser>(_foll);
  }

  final String userID;
  final HSDatabaseRepository _databaseRepository;

  bool get isOwnProfile => userID == currentUser.uid;

  bool isUserFollowed(HSUser user) {
    return user.followers != null && user.followers!.contains(currentUser.uid);
  }

  Future<void> _foll(event, emit) async {
    try {
      late final bool isFollow;

      emit(UserProfileUpdating(event.user));
      if (isUserFollowed(event.user)) {
        await _databaseRepository.unfollowUser(currentUser, event.user);
        isFollow = false;
      } else {
        await _databaseRepository.followUser(currentUser, event.user);
        isFollow = true;
      }
      HSDebugLogger.logSuccess(
          "The user has been: ${isFollow ? "followed" : "unfollowed"}");
      emit(UserProfileLoaded(_getUpdatedUser(event.user, isFollow)));
    } catch (_) {
      HSDebugLogger.logError("Error following / unfollowing user");
    }
  }

  HSUser _getUpdatedUser(HSUser user, bool isFollow) {
    late final HSUser ret;
    if (isFollow) {
      if (user.followers != null) {
        user.followers!.add(currentUser.uid);
        ret = user;
      } else {
        ret = user.copyWith(followers: [currentUser.uid]);
      }
    } else {
      user.followers!.remove(currentUser.uid);
      ret = user;
    }
    return ret;
  }

  void emitError(event, emit, {required String message}) {
    emit(UserProfileError(message));
  }

  Future<void> _fetchUserData(event, emit) async {
    try {
      HSUser? userData =
          await _databaseRepository.getUserFromDatabase(event.userID);
      if (userData == null) {
        throw const DatabaseConnectionFailure(
            "The user data could not be fetched. Please try again later.");
      }
      emit(UserProfileLoaded(userData));
    } on DatabaseConnectionFailure catch (_) {
      emitError(event, emit, message: _.message);
    } catch (_) {
      emitError(event, emit, message: _.toString());
    }
  }
}
