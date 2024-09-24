import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_database_repository/src/boards/hs_boards_repository.dart';
import 'package:hs_database_repository/src/cache/hs_cache_repository.dart';
import 'package:hs_database_repository/src/notifications/hs_notifications_repository.dart';
import 'package:hs_database_repository/src/recommendation_system/hs_recommendation_system_repository.dart';
import 'package:hs_database_repository/src/spots/hs_spots_repository.dart';
import 'package:hs_database_repository/src/tags/hs_tags_repository.dart';
import 'package:pair/pair.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HSDatabaseRepsitory {
  HSDatabaseRepsitory(this._supabaseClient) {
    _notificationsRepository = HSNotificationsRepository(_supabaseClient);
    _usersRepository =
        HSUsersRepository(_supabaseClient, users, _notificationsRepository);
    _boardsRepository =
        HSBoardsRepository(_supabaseClient, boards, _notificationsRepository);
    _spotsRepository =
        HSSpotsRepository(_supabaseClient, spots, _notificationsRepository);
    _tagsRepository = HSTagsRepository(_supabaseClient, spots);
    _recommendationSystemRepository =
        HSRecommendationSystemRepository(_supabaseClient);
  }

  static const String users = "users";
  static const String boards = "boards";
  static const String spots = "spots";
  static const String tags = "tags";
  static const String notifications = "notifications";
  final SupabaseClient _supabaseClient;
  late final HSUsersRepository _usersRepository;
  late final HSBoardsRepository _boardsRepository;
  late final HSSpotsRepository _spotsRepository;
  late final HSTagsRepository _tagsRepository;
  late final HSRecommendationSystemRepository _recommendationSystemRepository;
  late final HSNotificationsRepository _notificationsRepository;
  final HSCacheRepository _cacheRepository = HSCacheRepository();

  Future<void> userCreate({required HSUser user}) async =>
      await _usersRepository.create(user);

  Future<HSUser> userRead(
      {HSUser? user, String? userID, bool useCache = false}) async {
    if (useCache) {
      final cachedUser = _cacheRepository.getCachedUser(userID ?? user!.uid!);

      if (cachedUser != null) {
        return cachedUser;
      }
    }

    final fetchedUser = await _usersRepository.read(user, userID);

    _cacheRepository.cacheUser(
      userID: fetchedUser.uid,
      user: fetchedUser,
      userBoards: null,
      userSpots: null,
    );

    return fetchedUser;
  }

  Future<void> userUpdate({required HSUser user}) async =>
      await _usersRepository.update(user);

  Future<bool> userIsUsernameAvailable({required String username}) async =>
      await _usersRepository.isUsernameAvailable(username);

  Future<bool?> userIsUserFollowed(
      {String? followerID,
      HSUser? follower,
      String? followedID,
      HSUser? followed,
      bool useCache = false}) async {
    if (useCache) {
      final cachedIsUserFollowed = _cacheRepository.getCachedIsUserFollowed(
          followerID ?? follower!.uid!, followedID ?? followed!.uid!);

      if (cachedIsUserFollowed != null) {
        return cachedIsUserFollowed;
      }
    }

    final isUserFollowed = await _usersRepository.isUserFollowed(
        followerID, follower, followedID, followed);

    _cacheRepository.cacheUser(
      userID: followerID ?? follower!.uid!,
      user: null,
      userBoards: null,
      userSpots: null,
      isUserFollowed: Pair(followedID ?? followed!.uid!, isUserFollowed!),
    );

    return isUserFollowed;
  }

  Future<void> userFollow(
      {required bool isFollowed,
      String? followerID,
      String? followedID,
      HSUser? follower,
      HSUser? followed}) async {
    final bool? foll = await userIsUserFollowed(
        followedID: followedID, followerID: followerID);
    if (foll!) {
      await _usersRepository.unfollow(
          followerID, followedID, follower, followed);
    } else {
      await _usersRepository.follow(followerID, followedID, follower, followed);
    }
  }

  Future<String> boardCreate({required HSBoard board}) async =>
      await _boardsRepository.create(board);

  Future<HSBoard> boardRead({HSBoard? board, String? boardID}) async =>
      await _boardsRepository.read(board, boardID);

  Future<void> boardUpdate({required HSBoard board}) async =>
      await _boardsRepository.update(board);

  Future<void> boardDelete({required HSBoard board}) async =>
      await _boardsRepository.delete(board);

  Future<bool> boardIsBoardSaved(
          {HSBoard? board, String? boardID, HSUser? user, String? userID}) =>
      _boardsRepository.isBoardSaved(board, boardID, user, userID);

  Future<bool> boardIsEditor(
          {HSBoard? board, String? boardID, HSUser? user, String? userID}) =>
      _boardsRepository.isEditor(board, boardID, user, userID);

  Future<bool> boardSaveUnsave(
          {HSBoard? board, String? boardID, HSUser? user, String? userID}) =>
      _boardsRepository.saveUnsave(board, boardID, user, userID);

  Future<List<HSBoard>> boardFetchSavedBoards(
      {HSUser? user, String? userID, bool useCache = false}) async {
    if (useCache) {
      final cachedBoards = _cacheRepository.getCachedSavedBoards();
      if (cachedBoards != null) {
        return cachedBoards;
      }
    }

    final fetchedBoards =
        await _boardsRepository.fetchSavedBoards(user, userID);
    _cacheRepository.cacheSavedData(savedBoards: fetchedBoards);

    return fetchedBoards;
  }

  Future<List<HSBoard>> boardFetchTrendingBoards(
          {int batchOffset = 0, int batchSize = 10}) async =>
      await _boardsRepository.fetchTrendingBoards(batchOffset, batchSize);

  Future<List<HSSpot>> boardFetchBoardSpots(
          {HSBoard? board, String? boardID}) async =>
      await _boardsRepository.fetchBoardSpots(board, boardID);

  Future<List<HSUser>> boardFetchBoardCollaborators(
          {HSBoard? board, String? boardID}) async =>
      await _boardsRepository.fetchBoardCollaborators(board, boardID);

  Future<bool> boardAddSpot(
          {HSBoard? board,
          String? boardID,
          HSSpot? spot,
          String? spotID,
          HSUser? addedBy,
          String? addedByID}) async =>
      await _boardsRepository.addSpot(
          board, boardID, spot, spotID, addedBy, addedByID);

  Future<void> boardRemoveSpot(
          {HSBoard? board,
          String? boardID,
          HSSpot? spot,
          String? spotID}) async =>
      await _boardsRepository.removeSpot(board, boardID, spot, spotID);

  Future<void> boardUpdateSpotIndex(
          {HSBoard? board,
          String? boardID,
          String? spotID,
          HSSpot? spot,
          required int newIndex}) async =>
      await _boardsRepository.updateSpotIndex(
          board, boardID, spot, spotID, newIndex);

  Future<List<HSBoard>> boardFetchUserBoards({
    HSUser? user,
    String? userID,
    int batchOffset = 0,
    int batchSize = 20,
    bool useCache = false,
  }) async {
    if (useCache) {
      final cachedBoards =
          _cacheRepository.getCachedUserBoards(userID ?? user!.uid!);

      if (cachedBoards != null) {
        return cachedBoards;
      }
    }

    final fetchedBoards = await _boardsRepository.fetchUserBoards(
        user, userID, batchOffset, batchSize);

    _cacheRepository.cacheUser(
      userID: userID ?? user!.uid!,
      user: null,
      userBoards: fetchedBoards,
      userSpots: null,
    );

    return fetchedBoards;
  }

  Future<String> boardGenerateBoardInvitation(
          {required String boardId}) async =>
      await _boardsRepository.generateBoardInvitation(boardId);

  Future<bool> boardCheckIfInvitationIsValid(
          {required String boardId,
          required String token,
          required String userId}) async =>
      await _boardsRepository.checkIfInvitationIsValid(boardId, token, userId);

  Future<void> boardAddCollaborator(
          {required String boardId, required String userId}) async =>
      await _boardsRepository.addCollaborator(boardId, userId);

  Future<void> boardRemoveCollaborator(
          {required String boardId, required String userId}) async =>
      await _boardsRepository.removeCollaborator(boardId, userId);

  Future<HSBoard?> boardFetchBoardForInvitation(
          {required String boardId}) async =>
      await _boardsRepository.fetchBoardForInvitation(boardId);

  Future<void> boardAddPotentialCollaboratorAsInvited(
          {required String boardId, required String userId}) async =>
      await _boardsRepository.addPotentialCollaboratorAsInvited(
          boardId, userId);

  Future<void> boardRemovePotentialCollaboratorFromInvited(
          {required String boardId, required String userId}) async =>
      await _boardsRepository.removePotentialCollaboratorFromInvited(
          boardId, userId);

  Future<String> spotCreate({required HSSpot spot}) async =>
      await _spotsRepository.create(spot);

  Future<HSSpot> spotRead({HSSpot? spot, String? spotID}) async =>
      await _spotsRepository.read(spot, spotID);

  Future<void> spotUpdate({required HSSpot spot}) async =>
      await _spotsRepository.update(spot);

  Future<void> spotDelete({required HSSpot spot}) async =>
      await _spotsRepository.delete(spot);

  Future<void> spotUploadImages(
          {required String spotID,
          required List<Pair<String, String>> imageUrls,
          required String uid}) async =>
      await _spotsRepository.uploadImages(spotID, imageUrls, uid);

  Future<void> spotDeleteImages({HSSpot? spot, String? spotID}) async =>
      await _spotsRepository.deleteImages(spot, spotID);

  Future<HSComment> spotAddComment(
          {required String spotID,
          required String userID,
          required String comment,
          required bool isReply,
          String? parentCommentID}) async =>
      await _spotsRepository.addComment(
          spotID, userID, comment, isReply, parentCommentID);

  Future<List<HSSpot>> spotFetchSpotsWithinRadius(
          {required double lat, required double long, double? radius}) async =>
      await _spotsRepository.fetchSpotsWithinRadius(lat, long, radius);

  Future<HSUser> spotFetchAuthor({HSSpot? spot, String? authorID}) async =>
      await _spotsRepository.fetchSpotAuthor(spot, authorID);

  Future<HSSpot> spotfetchSpotWithAuthor(
          {HSSpot? spot, String? spotID}) async =>
      await _spotsRepository.fetchSpotWithAuthor(spot, spotID);

  Future<void> spotDislike(
          {HSSpot? spot, String? spotID, HSUser? user, String? userID}) async =>
      await _spotsRepository.dislike(spot, spotID, user, userID);
  Future<void> spotLike(
          {HSSpot? spot, String? spotID, HSUser? user, String? userID}) async =>
      await _spotsRepository.like(spot, spotID, user, userID);
  Future<bool> spotIsSpotLiked(
          {HSSpot? spot, String? spotID, HSUser? user, String? userID}) async =>
      await _spotsRepository.isSpotLiked(spot, spotID, user, userID);

  Future<bool> spotLikeDislike(
          {HSSpot? spot, String? spotID, HSUser? user, String? userID}) async =>
      await _spotsRepository.likeDislike(spot, spotID, user, userID);

  Future<bool> spotIsSaved(
          {HSSpot? spot, String? spotID, HSUser? user, String? userID}) async =>
      await _spotsRepository.isSaved(spot, spotID, user, userID);

  Future<bool> spotSaveUnsave(
          {HSSpot? spot, String? spotID, HSUser? user, String? userID}) async =>
      await _spotsRepository.saveUnsave(spot, spotID, user, userID);

  Future<List<HSSpot>> spotFetchSpotsInView({
    required double minLat,
    required double minLong,
    required double maxLat,
    required double maxLong,
  }) async =>
      await _spotsRepository.fetchInView(
        minLat,
        minLong,
        maxLat,
        maxLong,
      );

  /// Fetches the spots that belong to the user of given UID and are visible to the requester.
  ///
  /// The requester can be the user themselves or another user.
  ///
  /// The requester can specify the batch offset and batch size to fetch the spots in batches for pagination purposes.
  Future<List<HSSpot>> spotFetchUserSpots({
    HSUser? user,
    String? userID,
    int batchOffset = 0,
    int batchSize = 20,
    bool useCache = false,
  }) async {
    if (useCache) {
      final cachedSpots =
          _cacheRepository.getCachedUserSpots(userID ?? user!.uid!);

      if (cachedSpots != null) {
        return cachedSpots;
      }
    }

    final fetchedSpots =
        await _spotsRepository.userSpots(user, userID, batchOffset, batchSize);

    _cacheRepository.cacheUser(
      userID: userID ?? user!.uid!,
      user: null,
      userBoards: null,
      userSpots: fetchedSpots,
    );

    return fetchedSpots;
  }

  Future<HSSpot> spotFetchTopSpotWithTag(String tag) async =>
      await _spotsRepository.fetchTopSpotWithTag(tag);

  Future<List<HSSpot>> spotFetchTrendingSpots(
          {int batchSize = 20,
          int batchOffset = 0,
          double? lat,
          double? long}) async =>
      await _spotsRepository.fetchTrendingSpots(
          batchSize, batchOffset, lat, long);

  Future<List<HSComment>> spotFetchComments(
          {required String spotID,
          required String userID,
          required int currentPageOffset,
          required bool isReply}) async =>
      await _spotsRepository.fetchComments(
          spotID, userID, currentPageOffset, isReply);

  Future<void> spotLikeOrDislikeComment(
          {required String commentID, required String userID}) async =>
      await _spotsRepository.likeOrDislikeComment(commentID, userID);

  Future<void> spotRemoveComment(
          {required String commentID, required String userID}) async =>
      await _spotsRepository.removeComment(commentID, userID);

  Future<List<HSSpot>> spotFetchSaved(
      {required String userID,
      int batchSize = 10,
      int batchOffset = 0,
      bool useCache = false}) async {
    if (useCache) {
      final cachedSpots = _cacheRepository.getCachedSavedSpots();

      if (cachedSpots != null) {
        return cachedSpots;
      }
    }

    final savedSpots =
        await _spotsRepository.fetchSavedSpots(userID, batchSize, batchOffset);

    _cacheRepository.cacheSavedData(savedSpots: savedSpots);

    return savedSpots;
  }

  Future<List<HSSpot>> spotFetchClosest(
          {required double lat,
          required double long,
          int batchSize = 20,
          int batchOffset = 0,
          double distance = 60.0}) async =>
      await _spotsRepository.fetchClosest(
          lat, long, batchSize, batchOffset, distance);

  Future<void> tagCreate({required String tag}) async =>
      await _tagsRepository.create(tag);
  Future<HSTag> tagRead({HSTag? tag, String? tagID}) async =>
      await _tagsRepository.read(tag, tagID);
  Future<void> tagUpdate({required HSTag tag}) async =>
      await _tagsRepository.update(tag);
  Future<void> tagDelete({required HSTag tag}) async =>
      await _tagsRepository.delete(tag);
  Future<void> tagSpotCreate(
          {required String value,
          required String userID,
          required String spotID}) async =>
      await _tagsRepository.createSpot(value, userID, spotID);
  Future<void> tagSpotDelete({required String tag}) async =>
      await _tagsRepository.deleteSpot(tag);
  Future<bool> tagExists({required String tagValue}) async =>
      await _tagsRepository.tagExists(tagValue);
  Future<List<HSTag>> tagFetchSpotTags({HSSpot? spot, String? spotID}) async =>
      await _tagsRepository.fetchSpotTags(spot, spotID);
  Future<void> tagDeleteSpotTags(
          {HSSpot? spot, String? spotID, List<String>? tags}) async =>
      await _tagsRepository.deleteSpotTags(spot, spotID, tags);
  Future<List<HSTag>> tagSearch(
          {required String query,
          int batchOffset = 0,
          int batchSize = 20}) async =>
      _tagsRepository.search(query, batchOffset, batchSize);

  Future<List<HSSpot>> tagFetchTopSpots(
          {required String tag,
          int batchSize = 20,
          int batchOffset = 0}) async =>
      await _tagsRepository.fetchTopSpots(tag, batchSize, batchOffset);

  Future<void> recommendationSystemCaptureEvent(
          {required String userId,
          required HSSpot spot,
          required HSInteractionType event}) async =>
      await _recommendationSystemRepository.captureEvent(userId, spot, event);

  Future<void> notifactionChangeFcmToken(
          {required String userID, required String fcmToken}) async =>
      await _notificationsRepository.changeFcmToken(userID, fcmToken);

  Future<void> notificationCreate(
          {required HSNotification notificaton}) async =>
      await _notificationsRepository.create(notificaton);

  Future<HSNotification> notificationRead(
          {HSNotification? notification, String? notificationID}) async =>
      _notificationsRepository.read(notification, notificationID);

  Future<List<HSNotification>> notificationReadUserNotifications(
          {HSUser? currentUser,
          String? currentUserID,
          int limit = 20,
          int offset = 0,
          bool includeHidden = false}) async =>
      await _notificationsRepository.readUserNotifications(
          currentUser, currentUserID, limit, offset, includeHidden);

  Future<void> notificationMarkAsRead({required String id}) async =>
      _notificationsRepository.notificationMarkAsRead(id);
  Future<bool> notificationIsRead({required String id}) async =>
      _notificationsRepository.notificationIsRead(id);

  Future<HSAnnouncement?> announcementGetByID(String id) async =>
      _notificationsRepository.announcementGetByID(id);
  Future<List<HSAnnouncement>> announcementGetRecent({
    int batchLimit = 10,
    int batchOffset = 0,
  }) async =>
      _notificationsRepository.announcementGetRecent(batchLimit, batchOffset);

  Future<void> announcementMarkAsRead({required String id}) async =>
      _notificationsRepository.announcementMarkAsRead(id);
  Future<bool> announcementIsRead({required String id}) async =>
      _notificationsRepository.announcementIsRead(id);
}
