import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';

part 'hs_user_profile_updated_state.dart';

class HsUserProfileUpdatedCubit extends Cubit<HsUserProfileUpdatedState> {
  HsUserProfileUpdatedCubit(this.userID)
      : super(const HsUserProfileUpdatedState()) {
    _init();
  }

  final String userID;
  final _databaseRepository = app.databaseRepository;

  void _init() async {
    try {
      emit(state.copyWith(status: HSUserProfileUpdatedStatus.loading));
      final user = await _databaseRepository.userRead(userID: userID);
      final spots =
          await _databaseRepository.spotFetchUserSpots(userID: userID);
      final boards =
          await _databaseRepository.boardFetchUserBoards(userID: userID);
      emit(state.copyWith(
        user: user,
        followersCount: user.followers,
        followingCount: user.following,
        spots: spots,
        boards: boards,
        spotsCount: spots.length,
        status: HSUserProfileUpdatedStatus.ready,
      ));
    } catch (e) {
      emit(state.copyWith(status: HSUserProfileUpdatedStatus.error));
      HSDebugLogger.logError('Failed to load user profile $e');
    }
  }
}
