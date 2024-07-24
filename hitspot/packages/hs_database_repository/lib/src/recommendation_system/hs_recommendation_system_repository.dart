import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'hs_interaction_type.dart';

bool isGatheringInformationOn = true;

class HSRecommendationSystemRepository {
  const HSRecommendationSystemRepository(this._supabase);

  final SupabaseClient _supabase;

  Future<void> captureEvent(
      String userId, HSSpot spot, HSInteractionType event) async {
    try {
      if (!isGatheringInformationOn) {
        return;
      }

      if (userId == "" || spot.sid == "") {
        HSDebugLogger.logError(
            "Capturing event failed - invalid userId or spotId");
        return;
      }

      // Don't capture events for the author of the spot
      if (spot.createdBy == userId) {
        return;
      }

      String eventAsString = event.toString().split('.').last;

      await _supabase.from('interactions').insert({
        'user_id': userId,
        'spot_id': spot.sid,
        'interaction_type': eventAsString,
      });
      HSDebugLogger.logInfo("Event captured - ${eventAsString}!");
    } catch (_) {
      HSDebugLogger.logError("Error capturing event: $_");
    }
  }
}
