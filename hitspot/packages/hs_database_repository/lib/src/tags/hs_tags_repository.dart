import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_database_repository/src/tags/hs_tag.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HSTagsRepository {
  const HSTagsRepository(this._supabase, this._tableName);
  final String _tableName;
  final SupabaseClient _supabase;

  // CREATE
  Future<void> create(String value) async {
    try {
      await _supabase.rpc('tags_create_tag', params: {
        'tag_value_input': value,
      });
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
      await _supabase.rpc('spots_tags_add_tag', params: {
        'tag_value_input': value,
        'user_id_input': userID,
        'spot_id_input': spotID,
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
    } catch (_) {
      throw Exception("Error creating spot tag: $_");
    }
  }

  Future<List<HSTag>> fetchSpotTags(HSSpot? spot, String? spotID) async {
    try {
      assert(spot != null || spotID != null, "Spot or spotID must be provided");
      final sid = spot?.sid ?? spotID;
      final List response =
          await _supabase.rpc('spots_tags_fetch_tags_of_spot', params: {
        'spot_id_input': sid,
      });
      HSDebugLogger.logSuccess("Fetched : $response");
      final List<HSTag> tags =
          response.map((e) => HSTag.deserialize(e)).toList();
      return tags;
    } catch (_) {
      throw Exception("Error reading spot tags: $_");
    }
  }

  Future<List<HSTag>> search(
      String query, int batchOffset, int batchSize) async {
    try {
      final List<Map<String, dynamic>> response =
          await _supabase.rpc('tags_query_tag', params: {
        'query': query,
        "batch_offset": batchOffset,
        "batch_size": batchSize,
      });
      final List<HSTag> tags =
          response.map((e) => HSTag.deserialize(e)).toList();
      return tags;
    } catch (_) {
      throw Exception("Error searching tags: $_");
    }
  }
}
