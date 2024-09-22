import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_database_repository/src/notifications/hs_notifications_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:pair/pair.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HSSpotsRepository {
  const HSSpotsRepository(
      this._supabase, this._spots, this._notificationsRepository);

  final SupabaseClient _supabase;
  final String _spots;
  final String _spotsImages = "spots_images";
  final HSNotificationsRepository _notificationsRepository;

  // CREATE
  Future<String> create(HSSpot spot) async {
    try {
      HSDebugLogger.logInfo("Creating spot: ${spot.serialize()}");
      final insertedSpot =
          await _supabase.from(_spots).insert(spot.serialize()).select();
      HSDebugLogger.logSuccess("Spot created: ${insertedSpot.isNotEmpty}");
      return insertedSpot.first['id'];
    } catch (_) {
      throw Exception("Error creating spot: $_");
    }
  }

  // READ
  Future<HSSpot> read(HSSpot? spot, String? spotID) async {
    assert(spot != null || spotID != null, "Spot or spotID must be provided");
    try {
      final sid = spot?.sid ?? spotID!;
      final fetchedSpot =
          await _supabase.rpc('spot_fetch', params: {'p_spot_id': sid});
      if (fetchedSpot.isEmpty) throw "Spot not found";
      HSDebugLogger.logInfo("Fetched: ${fetchedSpot.toString()}");
      return HSSpot.deserialize(fetchedSpot.first);
    } catch (_) {
      throw Exception("Error reading spot: $_");
    }
  }

  // UPDATE
  Future<void> update(HSSpot spot) async {
    try {
      await _supabase.from(_spots).update(spot.serialize()).eq("id", spot.sid!);
      HSDebugLogger.logSuccess("Spot (${spot.sid}) data updated!");
    } catch (_) {
      throw Exception("Error updating spot: $_");
    }
  }

  // DELETE
  Future<void> delete(HSSpot spot) async {
    try {
      await _supabase.from(_spots).delete().eq("id", spot.sid!);
      HSDebugLogger.logSuccess("Spot (${spot.sid}) deleted!");
    } catch (_) {
      throw Exception("Error deleting spot: $_");
    }
  }

  // UPLOAD IMAGES
  Future<void> uploadImages(
      String spotID, List<Pair<String, String>> imageUrls, String uid) async {
    try {
      for (var i = 0; i < imageUrls.length; i++) {
        final String url = imageUrls[i].key;
        final String thumbnailUrl = imageUrls[i].value;

        await _supabase.from(_spotsImages).insert({
          "spot_id": spotID,
          "image_url": url,
          "thumbnail_url": thumbnailUrl,
          "created_by": uid,
          "image_type": "image",
        });
      }
      HSDebugLogger.logSuccess("Images uploaded: ${imageUrls.length}");
    } catch (_) {
      throw Exception("Error uploading images: $_");
    }
  }

  Future<void> deleteImages(HSSpot? spot, String? spotID) async {
    try {
      final sid = spot?.sid ?? spotID!;
      await _supabase.from(_spotsImages).delete().eq("spot_id", sid);
    } catch (e) {
      throw Exception("Error deleting images: $e");
    }
  }

  Future<List<HSSpot>> fetchSpotsWithinRadius(double lat, double long,
      [double? radius]) async {
    const double DEFAULT_RADIUS = 1000 * 50; // 50km
    try {
      final List<Map<String, dynamic>> data =
          await _supabase.rpc('spot_fetch_within_radius', params: {
        'p_lat': lat,
        'p_long': long,
        'p_radius': radius ?? DEFAULT_RADIUS,
      });
      final List<HSSpot> spots =
          data.map(HSSpot.deserializeWithAuthor).toList();
      return (spots);
    } catch (_) {
      HSDebugLogger.logError(_.toString());
      throw Exception("Error fetching spots within radius: $_");
    }
    // TODO: Add map view with clustering (https://pub.dev/packages/google_maps_cluster_manager)
  }

  Future<List<String>> fetchSpotImages(
      HSSpot? spot, String? spotID, bool fetchThumbnails) async {
    assert(spot != null || spotID != null, "Spot or spotID must be provided");
    try {
      final sid = spot?.sid ?? spotID!;
      final List<Map<String, dynamic>> data =
          await _supabase.rpc("spot_fetch_images", params: {'p_spot_id': sid});
      late List<String> imageUrls;

      if (fetchThumbnails) {
        imageUrls = data
            .map((e) => (e['thumbnail_url'] != null
                ? e['thumbnail_url']
                : e['image_url']) as String)
            .toList();
      } else {
        imageUrls = data.map((e) => e['image_url'] as String).toList();
      }
      return imageUrls;
    } catch (_) {
      HSDebugLogger.logError(_.toString());
      throw Exception("Error fetching spot images: $_");
    }
  }

  Future<HSSpot> _composeSpotWithImages(
      HSSpot spot, bool fetchThumbnails) async {
    try {
      final List<String> images =
          await fetchSpotImages(spot, null, fetchThumbnails);
      return spot.copyWith(images: images);
    } catch (_) {
      HSDebugLogger.logError("Error composing spot with images: $_");
      throw Exception("Error composing spot with images: $_");
    }
  }

  Future<HSUser> fetchSpotAuthor(HSSpot? spot, String? userID) async {
    try {
      final uid = spot?.createdBy ?? userID!;
      final data =
          await _supabase.from("users").select().eq("id", uid).select();
      return HSUser.deserialize(data.first);
    } catch (_) {
      throw Exception("Could not fetch spot author: $_");
    }
  }

  Future<HSSpot> fetchSpotWithAuthor(HSSpot? spot, String? spotID) async {
    assert(spot != null || spotID != null, "Spot or spotID must be provided");
    assert(spot != null || spotID != null, "Spot or spotID must be provided");
    try {
      final sid = spot?.sid ?? spotID!;
      final fetchedSpot = await _supabase
          .rpc('spot_fetch_with_author', params: {'p_spot_id': sid});
      return HSSpot.deserializeWithAuthor(fetchedSpot.first);
    } catch (_) {
      throw Exception("Could not fetch spot with author: $_");
    }
  }

  Future<bool> isSpotLiked(
      HSSpot? spot, String? spotID, HSUser? user, String? userID) async {
    try {
      assert(spot != null || spotID != null, "Spot or spotID must be provided");
      final sid = spot?.sid ?? spotID!;
      final uid = user?.uid ?? userID!;
      final bool data = await _supabase
          .rpc('spot_is_liked', params: {'p_spot_id': sid, 'p_user_id': uid});
      return data;
    } catch (_) {
      throw Exception("Error checking if spot is liked: $_");
    }
  }

  Future<void> like(
      HSSpot? spot, String? spotID, HSUser? user, String? userID) async {
    try {
      assert(spot != null || spotID != null, "Spot or spotID must be provided");
      final sid = spot?.sid ?? spotID!;
      final uid = user?.uid ?? userID!;
      await _supabase
          .rpc('spot_like', params: {'p_spot_id': sid, 'p_user_id': uid});
      final authorID = spot?.createdBy;
      HSDebugLogger.logInfo("Spot author ID: ${spot?.createdBy}");
      assert(authorID != null, "Spot author ID must be provided");
    } catch (_) {
      throw Exception("Error liking spot: $_");
    }
  }

  Future<void> dislike(
      HSSpot? spot, String? spotID, HSUser? user, String? userID) async {
    try {
      assert(spot != null || spotID != null, "Spot or spotID must be provided");
      final sid = spot?.sid ?? spotID!;
      final uid = user?.uid ?? userID!;
      await _supabase
          .rpc('spot_dislike', params: {'p_spot_id': sid, 'p_user_id': uid});
    } catch (_) {
      throw Exception("Error disliking spot: $_");
    }
  }

  Future<bool> likeDislike(
      HSSpot? spot, String? spotID, HSUser? user, String? userID) async {
    try {
      assert(spot != null || spotID != null, "Spot or spotID must be provided");
      if (await isSpotLiked(spot, spotID, user, userID)) {
        await dislike(spot, spotID, user, userID);
        return false;
      } else {
        await like(spot, spotID, user, userID);
        return true;
      }
    } catch (_) {
      throw Exception("Error disliking spot: $_");
    }
  }

  Future<bool> isSaved(
      HSSpot? spot, String? spotID, HSUser? user, String? userID) async {
    try {
      assert(spot != null || spotID != null, "Spot or spotID must be provided");
      final sid = spot?.sid ?? spotID!;
      final uid = user?.uid ?? userID!;
      final bool data = await _supabase
          .rpc('spot_is_saved', params: {'p_spot_id': sid, 'p_user_id': uid});
      return data;
    } catch (_) {
      throw Exception("Error checking if spot is saved: $_");
    }
  }

  Future<void> _save(
      HSSpot? spot, String? spotID, HSUser? user, String? userID) async {
    try {
      assert(spot != null || spotID != null, "Spot or spotID must be provided");
      final sid = spot?.sid ?? spotID!;
      final uid = user?.uid ?? userID!;
      await _supabase
          .rpc('spot_save', params: {'p_spot_id': sid, 'p_user_id': uid});
    } catch (_) {
      throw Exception("Error saving spot: $_");
    }
  }

  Future<void> _unsave(
      HSSpot? spot, String? spotID, HSUser? user, String? userID) async {
    try {
      assert(spot != null || spotID != null, "Spot or spotID must be provided");
      final sid = spot?.sid ?? spotID!;
      final uid = user?.uid ?? userID!;
      await _supabase
          .rpc('spot_unsave', params: {'p_spot_id': sid, 'p_user_id': uid});
    } catch (_) {
      throw Exception("Error unsaving spot: $_");
    }
  }

  Future<bool> saveUnsave(
      HSSpot? spot, String? spotID, HSUser? user, String? userID) async {
    try {
      assert(spot != null || spotID != null, "Spot or spotID must be provided");
      if (await isSaved(spot, spotID, user, userID)) {
        await _unsave(spot, spotID, user, userID);
        return false;
      } else {
        await _save(spot, spotID, user, userID);
        return true;
      }
    } catch (_) {
      throw Exception("Error saving / unsaving spot: $_");
    }
  }

  Future<List<HSSpot>> userSpots(
      HSUser? user, String? userID, int batchOffset, int batchSize) async {
    try {
      assert(user != null || userID != null, "User or userID must be provided");
      final uid = user?.uid ?? userID!;
      final List<Map<String, dynamic>> data = await _supabase
          .rpc('spot_fetch_user_spots', params: {
        'p_user_id': uid,
        'p_batch_offset': batchOffset,
        'p_batch_size': batchSize
      });
      final spots = data.map(HSSpot.deserialize).toList();
      for (var i = 0; i < spots.length; i++) {
        final spot =
            await _composeSpotWithImages(spots[i], /* with thumbnails */ true);
        spots[i] = spot;
      }
      return (spots);
    } catch (_) {
      throw Exception("Error fetching user spots: $_");
    }
  }

  Future<List<HSSpot>> fetchInView(
    double minLat,
    double minLong,
    double maxLat,
    double maxLong,
  ) async {
    try {
      final List<Map<String, dynamic>> data =
          await _supabase.rpc('spot_fetch_within_bounding_box', params: {
        'p_min_lat': minLat,
        'p_min_long': minLong,
        'p_max_lat': maxLat,
        'p_max_long': maxLong,
      });
      final List<HSSpot> spots =
          data.map(HSSpot.deserializeWithAuthor).toList();

      return spots;
    } catch (_) {
      throw Exception("Error fetching spots in view: $_");
    }
  }

  Future<HSSpot> fetchTopSpotWithTag(String tag) async {
    try {
      final List<Map<String, dynamic>> fetchedSpot = await _supabase
          .rpc('spot_fetch_top_spot_with_tag', params: {'p_tag': tag});
      return HSSpot.deserializeWithAuthor(fetchedSpot.first);
    } catch (_) {
      throw Exception("Error fetching top spot with tag: $_");
    }
  }

  Future<List<HSSpot>> fetchTrendingSpots(
      int? batchSize, int? batchOffset, double? lat, double? long) async {
    try {
      final List<Map<String, dynamic>> fetchedSpots =
          await _supabase.rpc('spot_fetch_trending', params: {
        'p_batch_size': batchSize,
        'p_batch_offset': batchOffset,
        'p_user_lat': lat,
        'p_user_long': long,
      });
      return fetchedSpots.map(HSSpot.deserializeWithAuthor).toList();
    } catch (_) {
      throw Exception("Error fetching trending spots: $_");
    }
  }

  Future<HSComment> addComment(String? spotID, String? userID, String comment,
      bool isReply, String? parentCommentID) async {
    try {
      assert(userID != null || spotID != null,
          "SpotID and userID must be provided");

      late final newComment;

      if (isReply) {
        newComment = await _supabase
            .from('spot_comments')
            .insert({
              'spot_id': spotID,
              'created_by': userID,
              'content': comment,
              'parent_id': parentCommentID,
            })
            .select()
            .single();
      } else {
        newComment = await _supabase
            .from('spot_comments')
            .insert({
              'spot_id': spotID,
              'created_by': userID,
              'content': comment,
            })
            .select()
            .single();
      }

      return HSComment.deserialize(newComment);
    } catch (_) {
      throw Exception("Error adding comment: $_");
    }
  }

  Future<List<HSComment>> fetchComments(
      String id, String userID, int currentPageOffset, bool isReply) async {
    try {
      // ID is either spotID (for normal comments) or commentID (for replies)

      assert(id.isNotEmpty && userID.isNotEmpty,
          "SpotID and userID must be provided");

      late final data;
      if (isReply) {
        data = await _supabase.rpc('spot_fetch_spot_comment_replies', params: {
          'p_comment_id': id,
          'p_limit': 8,
          'p_offset': currentPageOffset,
        });
      } else {
        data = await _supabase.rpc('spot_fetch_spot_comments', params: {
          'p_spot_id': id,
          'p_limit': 8,
          'p_offset': currentPageOffset,
        });
      }

      List<HSComment> fetchedComments =
          (data as List<dynamic>).map((e) => HSComment.deserialize(e)).toList();

      // Check if user liked these comments/replies
      for (int i = 0; i < fetchedComments.length; i++) {
        fetchedComments[i].isLiked =
            await _supabase.rpc('spot_has_user_liked_comment', params: {
          'p_comment_id': fetchedComments[i].id,
          'p_user_id': userID,
        });
      }

      return fetchedComments;
    } catch (_) {
      throw Exception("Error fetching spot comments: $_");
    }
  }

  Future<void> likeOrDislikeComment(
    String commentID,
    String userID,
  ) async {
    try {
      await _supabase.rpc('spot_like_or_dislike_comment', params: {
        'p_comment_id': commentID,
        'p_user_id': userID,
      });
    } catch (_) {
      throw Exception("Error liking comment: $_");
    }
  }

  Future<void> removeComment(String commentID, String userID) async {
    try {
      await _supabase
          .from("spot_comments")
          .delete()
          .eq("id", commentID)
          .eq("created_by", userID);
    } catch (_) {
      throw Exception("Error deleting comment: $_");
    }
  }

  Future<List<HSSpot>> fetchSavedSpots(
      String userID, int batchSize, int batchOffset) async {
    try {
      final List<Map<String, dynamic>> data = await _supabase
          .rpc('spot_fetch_saved', params: {
        'p_user_id': userID,
        'p_batch_size': batchSize,
        'p_batch_offset': batchOffset
      });
      return data.map(HSSpot.deserialize).toList();
    } catch (_) {
      throw Exception("Error fetching saved spots: $_");
    }
  }
}
