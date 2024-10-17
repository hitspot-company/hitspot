// import 'package:hs_database_repository/src/maintenance/hs_maintenance_info.dart';
// import 'package:hs_debug_logger/hs_debug_logger.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class HsMaintenanceRepository {
//   const HsMaintenanceRepository(this._supabaseClient);

//   final SupabaseClient _supabaseClient;

//   Future<HSMaintenanceInfo> fetchMaintenanceInfo() async {
//     try {
//       final res = await _supabaseClient.rpc('maintenance_fetch_info');
//       return HSMaintenanceInfo(
//         minVersion: ,
//         isUnderMaintenance: isUnderMaintenance)
//     } catch (e) {
//       HSDebugLogger.logError("[!] Failed to verify maintenance status: $e");
//       return true;
//     }
//   }
// }
