import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_database_repository/src/boards/hs_boards_repository.dart';
import 'package:hs_database_repository/src/spots/hs_spots_repository.dart';
import 'package:hs_database_repository/src/tags/hs_tags_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HSDatabaseRepsitory {
  HSDatabaseRepsitory(this._supabaseClient) {
    this._usersRepository = HSUsersRepository(_supabaseClient, users);
    this._boardsRepository = HSBoardsRepository(_supabaseClient, boards);
    this._spotsRepository = HSSpotsRepository(_supabaseClient, spots);
    this._tagsRepository = HSTagsRepository(_supabaseClient, spots);
  }

  static const String users = "users";
  static const String boards = "boards";
  static const String spots = "spots";
  static const String tags = "tags";
  final SupabaseClient _supabaseClient;
  late final HSUsersRepository _usersRepository;
  late final HSBoardsRepository _boardsRepository;
  late final HSSpotsRepository _spotsRepository;
  late final HSTagsRepository _tagsRepository;

  Future<void> userCreate({required HSUser user}) async =>
      await _usersRepository.create(user);

  Future<HSUser> userRead({HSUser? user, String? userID}) async =>
      await _usersRepository.read(user, userID);

  Future<void> userUpdate({required HSUser user}) async =>
      await _usersRepository.update(user);

  Future<bool> userIsUsernameAvailable({required String username}) async =>
      await _usersRepository.isUsernameAvailable(username);

  Future<bool?> userIsUserFollowed(
          {String? followerID,
          HSUser? follower,
          String? followedID,
          HSUser? followed}) async =>
      await _usersRepository.isUserFollowed(
          followerID, follower, followedID, followed);

  Future<void> userFollow(
      {required bool isFollowed,
      String? followerID,
      String? followedID,
      HSUser? follower,
      HSUser? followed}) async {
    final bool? foll = await userIsUserFollowed(
        followedID: followedID, followerID: followerID);
    if (foll!) {
      // HSDebugLogger.logInfo("User followed: Yes");
      await _usersRepository.unfollow(
          followerID, followedID, follower, followed);
    } else {
      // HSDebugLogger.logInfo("User followed: No");
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
          {HSUser? user, String? userID}) async =>
      await _boardsRepository.fetchSavedBoards(user, userID);

  Future<List<HSBoard>> boardFetchTrendingBoards() async =>
      await _boardsRepository.fetchTrendingBoards();

  Future<List<HSSpot>> boardFetchBoardSpots(
          {HSBoard? board, String? boardID}) async =>
      await _boardsRepository.fetchBoardSpots(board, boardID);

  Future<List<HSUser>> boardFetchBoardCollaborators(
          {HSBoard? board, String? boardID}) async =>
      await _boardsRepository.fetchBoardCollaborators(board, boardID);

  Future<void> boardAddSpot(
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
  }) async =>
      await _boardsRepository.fetchUserBoards(
          user, userID, batchOffset, batchSize);

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
          required List<String> imageUrls,
          required String uid}) async =>
      await _spotsRepository.uploadImages(spotID, imageUrls, uid);

  Future<List<HSSpot>> fetchNearbySpots(double lat, double long) async =>
      await _spotsRepository.fetchNearbySpots(lat, long);

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
  Future<List<HSSpot>> spotfetchUserSpots(
          {HSUser? user,
          String? userID,
          int batchOffset = 0,
          int batchSize = 20}) async =>
      await _spotsRepository.userSpots(user, userID, batchOffset, batchSize);

  Future<List<HSBoard>> spotfetchUserBoards(
          {HSUser? user,
          String? userID,
          int batchOffset = 0,
          int batchSize = 20}) async =>
      await _spotsRepository.userBoards(user, userID, batchOffset, batchSize);

  Future<HSSpot> spotFetchTopSpotWithTag(String tag) async =>
      await _spotsRepository.fetchTopSpotWithTag(tag);

  Future<List<HSSpot>> spotFetchTrendingSpots(
          {int batchSize = 20,
          int batchOffset = 0,
          double? lat,
          double? long}) async =>
      await _spotsRepository.fetchTrendingSpots(
          batchSize, batchOffset, lat, long);

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
}
