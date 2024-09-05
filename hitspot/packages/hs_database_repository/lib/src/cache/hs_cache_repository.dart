import 'dart:collection';

import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:pair/pair.dart';

const int MAXIMUM_CACHED_USERS = 16;

// TODO: ADD SAVING WITH SHARED PREFERENCES

// POSSIBLE TO CACHE:
// List<HSSpot>? _trendingSpots;
// List<HSBoard>? _trendingBoards;
// List<HSSpot>? _nearbySpots;

class _UserCacheData {
  final HSUser? user;
  final List<HSSpot>? userSpots;
  final List<HSBoard>? userBoards;
  Map<String, bool> userFollows = {};

  _UserCacheData({this.user, this.userSpots, this.userBoards});
}

class HSCacheRepository {
  int numberOfCachedUsers = 0;

  static final HSCacheRepository _instance = HSCacheRepository._internal();
  HSCacheRepository._internal();
  factory HSCacheRepository() => _instance;

  final LinkedHashMap<String, _UserCacheData> _cache = LinkedHashMap();

  void cacheUser({
    String? userID,
    HSUser? user,
    List<HSSpot>? userSpots,
    List<HSBoard>? userBoards,
    Pair<String, bool>? isUserFollowed,
  }) {
    assert(userID != null || user != null);

    final currentCachedUser = _cache[userID ?? user!.uid!];
    if (currentCachedUser == null) {
      numberOfCachedUsers++;
      // Remove second added user if cache is full (first added is probably user's own profile)
      if (numberOfCachedUsers > MAXIMUM_CACHED_USERS) {
        _cache.remove(_cache.keys.elementAt(1));
      }
    }

    _cache[userID ?? user!.uid!] = _UserCacheData(
      user: user ?? currentCachedUser?.user,
      userSpots: userSpots ?? currentCachedUser?.userSpots,
      userBoards: userBoards ?? currentCachedUser?.userBoards,
    );

    _cache[userID ?? user!.uid!]?.userFollows[isUserFollowed?.key ?? ""] =
        isUserFollowed?.value ?? false;
  }

  HSUser? getCachedUser(String userID) {
    return _cache[userID]?.user;
  }

  List<HSSpot>? getCachedUserSpots(String userID) {
    return _cache[userID]?.userSpots;
  }

  List<HSBoard>? getCachedUserBoards(String userID) {
    return _cache[userID]?.userBoards;
  }

  bool? isUserFollowed(String followerID, followedID) {
    return _cache[followerID]?.userFollows[followedID];
  }
}
