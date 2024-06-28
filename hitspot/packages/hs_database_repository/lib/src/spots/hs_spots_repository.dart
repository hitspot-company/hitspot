import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_database_repository/src/spots/hs_spot.dart';
import 'package:hs_database_repository/src/utils/utils.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HSSpotsRepository {
  const HSSpotsRepository(this._supabase, this._spots);

  final SupabaseClient _supabase;
  final String _spots;
  final String _spotsImages = "spots_images";

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
      final fetchedSpot = await _supabase.rpc('spots_fetch_spot', params: {
        'requested_spot_id': sid,
      });
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
      String spotID, List<String> imageUrls, String uid) async {
    try {
      for (var i = 0; i < imageUrls.length; i++) {
        final String url = imageUrls[i];
        await _supabase.from(_spotsImages).insert({
          "spot_id": spotID,
          "image_url": url,
          "created_by": uid,
          "image_type": "image",
        });
      }
      HSDebugLogger.logSuccess("Images uploaded: ${imageUrls.length}");
    } catch (_) {
      throw Exception("Error uploading images: $_");
    }
  }

  // Fetch nearby spots
  Future<List<HSSpot>> fetchNearbySpots(double lat, double long) async {
    const double DEFAULT_RADIUS = 4000000000.0;
    try {
      final data = await _supabase.rpc('spots_fetch_nearby_spots', params: {
        'lat': lat,
        'long': long,
      });
      HSDebugLogger.logInfo(data.toString());
      final List<HSSpot> spots =
          (data as List<dynamic>).map((e) => HSSpot.deserialize(e)).toList();
      return (spots);
    } catch (_) {
      HSDebugLogger.logError(_.toString());
      throw Exception("Error fetching nearby spots: $_");
    }

    // TODO: Add map view with clustering (https://pub.dev/packages/google_maps_cluster_manager)
  }

  Future<List<HSSpot>> fetchSpotsWithinRadius(double lat, double long,
      [double? radius]) async {
    const double DEFAULT_RADIUS = 1000 * 50; // 50km
    try {
      final data =
          await _supabase.rpc('spots_fetch_spots_within_radius', params: {
        'lat': lat,
        'long': long,
        'radius': radius ?? DEFAULT_RADIUS,
      });
      HSDebugLogger.logInfo(data.toString());
      final List<HSSpot> spots = (data as List<dynamic>).map((e) {
        print(data);
        return HSSpot.deserialize(e);
      }).toList();
      for (var i = 0; i < spots.length; i++) {
        final spot = await _composeSpotWithImages(spots[i]);
        spots[i] = spot;
      }
      return (spots);
    } catch (_) {
      HSDebugLogger.logError(_.toString());
      throw Exception("Error fetching spots within radius: $_");
    }
    // TODO: Add map view with clustering (https://pub.dev/packages/google_maps_cluster_manager)
  }

  Future<List<String>> fetchSpotImages(HSSpot? spot, String? spotID) async {
    assert(spot != null || spotID != null, "Spot or spotID must be provided");
    try {
      final sid = spot?.sid ?? spotID!;
      final data = await _supabase
          .rpc("spots_fetch_spot_images", params: {'requested_spot_id': sid});
      final List<String> imageUrls =
          (data as List<dynamic>).map((e) => e['image_url'] as String).toList();
      return imageUrls;
    } catch (_) {
      HSDebugLogger.logError(_.toString());
      throw Exception("Error fetching spot images: $_");
    }
  }

  Future<HSSpot> _composeSpotWithImages(HSSpot spot) async {
    try {
      final List<String> images = await fetchSpotImages(spot, null);
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
    try {
      final fetchedSpot =
          await _supabase.rpc('spots_fetch_spot_with_author', params: {
        'spotsid': spotID,
      });
      return HSSpotsUtils.deserializeSpotWithAuthor(fetchedSpot.first);
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
      final bool data = await _supabase.rpc('spots_is_spot_liked', params: {
        'requested_spot_id': sid,
        'requested_by_id': uid,
      });
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
      await _supabase.rpc('spots_like_spot', params: {
        'requested_spot_id': sid,
        'requested_by_id': uid,
      });
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
      await _supabase.rpc('spots_dislike_spot', params: {
        'requested_spot_id': sid,
        'requested_by_id': uid,
      });
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
      final bool data = await _supabase.rpc('spots_is_spot_saved', params: {
        'requested_spot_id': sid,
        'requested_by_id': uid,
      });
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
      await _supabase.rpc('spots_save_spot', params: {
        'requested_spot_id': sid,
        'requested_by_id': uid,
      });
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
      await _supabase.rpc('spots_unsave_spot', params: {
        'requested_spot_id': sid,
        'requested_by_id': uid,
      });
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
      final data = await _supabase.rpc('spots_fetch_user_spots', params: {
        'user_id': uid,
        'batch_offset': batchOffset,
        'batch_size': batchSize,
      });
      final List<HSSpot> spots =
          (data as List<dynamic>).map((e) => HSSpot.deserialize(e)).toList();
      for (var i = 0; i < spots.length; i++) {
        final spot = await _composeSpotWithImages(spots[i]);
        spots[i] = spot;
      }
      return (spots);
    } catch (_) {
      throw Exception("Error fetching user spots: $_");
    }
  }

  Future<List<HSBoard>> userBoards(
      HSUser? user, String? userID, int batchOffset, int batchSize) async {
    try {
      assert(user != null || userID != null, "User or userID must be provided");
      final uid = user?.uid ?? userID!;
      final data = await _supabase.rpc('fetch_user_boards', params: {
        'user_id': uid,
        'batch_offset': batchOffset,
        'batch_size': batchSize,
      });
      final List<HSBoard> boards =
          (data as List<dynamic>).map((e) => HSBoard.deserialize(e)).toList();
      return boards;
    } catch (_) {
      throw Exception("Error fetching user spots: $_");
    }
  }
}
