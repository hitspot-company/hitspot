import 'dart:collection';

import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:pair/pair.dart';

const int MAXIMUM_CACHED_USERS = 16;

// TODO: ADD SAVING WITH SHARED PREFERENCES - do we really need it?

class _UserCacheData {
  HSUser? user = null;
  List<HSSpot>? userSpots = null;
  List<HSBoard>? userBoards = null;
  Map<String, bool> userFollows = {};

  _UserCacheData({this.user, this.userSpots, this.userBoards});
}

class _SavedCacheData {
  final List<HSBoard>? savedBoards;
  final List<HSSpot>? savedSpots;

  _SavedCacheData({this.savedBoards, this.savedSpots});
}

class HSCacheRepository {
  static final HSCacheRepository _instance = HSCacheRepository._internal();
  HSCacheRepository._internal();
  factory HSCacheRepository() => _instance;

  int numberOfCachedUsers = 0;
  LinkedHashMap<String, _UserCacheData> _usersCache = LinkedHashMap();
  _SavedCacheData _savedCache = _SavedCacheData();

  void cacheUser({
    String? userID,
    HSUser? user,
    List<HSSpot>? userSpots,
    List<HSBoard>? userBoards,
    Pair<String, bool>? isUserFollowed,
  }) {
    assert(userID != null || user != null);

    final currentCachedUser = _usersCache[userID ?? user!.uid!];
    if (currentCachedUser == null) {
      numberOfCachedUsers++;
      // Remove second added user if cache is full (first added is probably user's own profile)
      if (numberOfCachedUsers > MAXIMUM_CACHED_USERS) {
        _usersCache.remove(_usersCache.keys.elementAt(1));
      }
    }

    _usersCache[userID ?? user!.uid!] = _UserCacheData(
      user: user ?? currentCachedUser?.user,
      userSpots: userSpots ?? currentCachedUser?.userSpots,
      userBoards: userBoards ?? currentCachedUser?.userBoards,
    );

    _usersCache[userID ?? user!.uid!]?.userFollows[isUserFollowed?.key ?? ""] =
        isUserFollowed?.value ?? false;
  }

  HSUser? getCachedUser(String userID) {
    return _usersCache[userID]?.user;
  }

  List<HSSpot>? getCachedUserSpots(String userID) {
    return _usersCache[userID]?.userSpots;
  }

  List<HSBoard>? getCachedUserBoards(String userID) {
    return _usersCache[userID]?.userBoards;
  }

  bool? getCachedIsUserFollowed(String followerID, followedID) {
    return _usersCache[followerID]?.userFollows[followedID];
  }

  void cacheSavedData({
    List<HSBoard>? savedBoards,
    List<HSSpot>? savedSpots,
  }) {
    _savedCache = _SavedCacheData(
      savedBoards: savedBoards ?? _savedCache.savedBoards,
      savedSpots: savedSpots ?? _savedCache.savedSpots,
    );
  }

  List<HSBoard>? getCachedSavedBoards() {
    return _savedCache.savedBoards;
  }

  List<HSSpot>? getCachedSavedSpots() {
    return _savedCache.savedSpots;
  }
}
