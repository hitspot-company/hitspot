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
}
