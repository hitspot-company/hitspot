import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HSTagsRepository {
  const HSTagsRepository(this._supabase, this._tableName);
  final String _tableName;
  final SupabaseClient _supabase;

  // CREATE
  Future<void> create(String value) async {
    try {
      await _supabase.rpc('tag_create', params: {'p_tag': value});
    } catch (error) {
      throw Exception("Error creating tag: $error");
    }
  }

  // READ
  Future<HSTag> read(HSTag? tag, String? tagID) async {
    try {
      assert(tag != null || tagID != null, "Tag or tagID must be provided");
      final tid = tag?.tid ?? tagID;
      final response =
          await _supabase.from(_tableName).select().eq("id", tid!).select();
      if (response.isEmpty) {
        throw Exception("Could not find the tag with id: $tid");
      }
      return HSTag.deserialize(response.first);
    } catch (error) {
      throw Exception("Error reading tags: $error");
    }
  }

  // UPDATE
  Future<void> update(HSTag tag) async {
    try {
      await _supabase
          .from(_tableName)
          .update(tag.serialize())
          .eq("id", tag.tid!);
    } catch (error) {
      throw Exception("Error updating tag: $error");
    }
  }

  // DELETE
  Future<void> delete(HSTag tag) async {
    try {
      await _supabase.rpc('tags_delete_tag', params: {
        'tag_value_input': tag.value,
      });
      // TODO: Add this function
    } catch (error) {
      throw Exception("Error deleting tag: $error");
    }
  }

  // EXISTS
  Future<bool> tagExists(String tagValue) async {
    try {
      final bool response = await _supabase.rpc('tags_tag_exists', params: {
        'tag_value_input': tagValue,
      });
      return response;
    } catch (error) {
      throw Exception("Error checking if tag exists: $error");
    }
  }

  Future<void> createSpot(String value, String userID, String spotID) async {
    try {
      await _supabase.rpc('spot_tags_create', params: {
        'p_tag': value,
        'p_user_id': userID,
        'p_spot_id': spotID,
      });
    } catch (_) {
      throw Exception("Error creating spot tag: $_");
    }
  }

  Future<void> deleteSpot(String value) async {
    try {
      await _supabase.rpc('spots_tags_delete_tag', params: {
        'tag_value_input': value,
      });
      // TODO: Add this function
    } catch (_) {
      throw Exception("Error creating spot tag: $_");
    }
  }

  Future<List<HSTag>> fetchSpotTags(HSSpot? spot, String? spotID) async {
    try {
      assert(spot != null || spotID != null, "Spot or spotID must be provided");
      final sid = spot?.sid ?? spotID;
      final List<Map<String, dynamic>> response =
          await _supabase.rpc('spot_fetch_tags', params: {'p_spot_id': sid});
      HSDebugLogger.logSuccess("Fetched : $response");
      final List<HSTag> tags = response.map(HSTag.deserialize).toList();
      return tags;
    } catch (_) {
      throw Exception("Error reading spot tags: $_");
    }
  }

  Future<List<HSSpot>> fetchTopSpots(
      String tag, int batchSize, int batchOffset) async {
    try {
      final List<Map<String, dynamic>> response =
          await _supabase.rpc('spot_fetch_with_tag', params: {
        "p_tag": tag,
        "p_batch_size": batchSize,
        "p_batch_offset": batchOffset,
      });
      HSDebugLogger.logSuccess("Fetched : $response");
      final List<HSSpot> spots = response.map(HSSpot.deserialize).toList();
      return spots;
    } catch (_) {
      throw Exception("Error reading spot tags: $_");
    }
  }

  Future<List<HSTag>> search(
      String query, int batchOffset, int batchSize) async {
    try {
      final List<Map<String, dynamic>> response =
          await _supabase.rpc('tag_query', params: {
        'p_query': query,
        "p_batch_offset": batchOffset,
        "p_batch_size": batchSize,
      });
      final List<HSTag> tags =
          response.map((e) => HSTag.deserialize(e)).toList();
      return tags;
    } catch (_) {
      throw Exception("Error searching tags: $_");
    }
  }
}
