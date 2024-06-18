import 'package:supabase_flutter/supabase_flutter.dart';

class HSSpotsRepository {
  const HSSpotsRepository(this._supabase, this._spots);

  final SupabaseClient _supabase;
  final String _spots;
}
