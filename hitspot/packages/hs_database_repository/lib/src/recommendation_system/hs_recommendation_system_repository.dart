import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'hs_interaction_type.dart';

bool isGatheringInformationOn = true;

class HSRecommendationSystemRepository {
  const HSRecommendationSystemRepository(this._supabase);

  final SupabaseClient _supabase;

  Future<void> captureEvent(
      String userId, String spotId, HSInteractionType event) async {
    try {
      if (!isGatheringInformationOn) {
        return;
      }

      if (userId == "" || spotId == "") {
        HSDebugLogger.logError(
            "Capturing event failed - invalid userId or spotId");
        return;
      }

      String eventAsString = event.toString().split('.').last;

      await _supabase.from('interactions').insert({
        'user_id': userId,
        'spot_id': spotId,
        'interaction_type': eventAsString,
      });
      HSDebugLogger.logInfo("Event captured - ${eventAsString}!");
    } catch (_) {
      HSDebugLogger.logError("Error capturing event: $_");
    }
  }
}
