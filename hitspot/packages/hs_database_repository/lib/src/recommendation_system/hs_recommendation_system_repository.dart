import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum HSInteractionType { nothing, like, comment, save, share, addedToBoard }

class HSRecommendationSystemRepository {
  const HSRecommendationSystemRepository(this._supabase);

  final SupabaseClient _supabase;

  Future<void> captureEvent(
      String userId, String spotId, HSInteractionType event) async {
    try {
      final response = await _supabase.from('interaction').insert([
        {
          'user_id': userId,
          'spot_id': spotId,
          'event':
              event.toString().split('.').last, // convert enum type to string
        }
      ]);
      HSDebugLogger.logInfo("Event captured: ${response.data}");
    } catch (_) {
      HSDebugLogger.logError("Error capturing event: $_");
    }
  }
}
