import 'dart:async'; // Import the dart:async library for Timer

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hitspot/main.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';

part 'hs_user_search_state.dart';

class HSUserSearchCubit extends Cubit<HSUserSearchState> {
  HSUserSearchCubit() : super(const HSUserSearchState());

  Timer? _debounce; // Define a Timer for debouncing

  void searchUsers(String query) {
    if (_debounce?.isActive ?? false) {
      _debounce?.cancel(); // Cancel previous timer if it exists and is active
    }

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      // Set debounce duration to 300 milliseconds
      emit(state.copyWith(status: HSUserSearchStatus.loading));
      try {
        await _search(query);
      } catch (e) {
        emit(state.copyWith(status: HSUserSearchStatus.error));
      }
    });
  }

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      emit(state.copyWith(status: HSUserSearchStatus.initial));
      return;
    }
    try {
      final result = await supabase
          .from('users')
          .select('name, username, id, avatar_url')
          .textSearch('fts', "$query:*")
          .limit(100);

      final List<HSUser> users =
          result.map<HSUser>((json) => HSUser.deserialize(json)).toList();
      emit(state.copyWith(status: HSUserSearchStatus.loaded, users: users));
      return;
    } catch (_) {
      HSDebugLogger.logError(_.toString());
      emit(state.copyWith(status: HSUserSearchStatus.error));
    }
  }

  @override
  Future<void> close() {
    _debounce?.cancel(); // Cancel debounce timer when the Cubit is closed
    return super.close();
  }
}
