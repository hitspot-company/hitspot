import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/src/spots/hs_spot.dart';
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
      final fetchedSpot = await _supabase.from(_spots).select().eq("id", sid);
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

    // TODO: Add fetching spots in the given radius (say 50km)
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
      final List<HSSpot> spots =
          (data as List<dynamic>).map((e) => HSSpot.deserialize(e)).toList();
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
}
