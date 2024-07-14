import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';

part 'hs_multiple_spots_state.dart';

class HsMultipleSpotsCubit extends Cubit<HsMultipleSpotsState> {
  HsMultipleSpotsCubit(this._type, {this.userID})
      : super(HsMultipleSpotsState(type: _type)) {
    pageTitle =
        _type == HsMultipleSpotsType.user ? '@username Spots' : 'All Spots';
    _init();
  }

  final HsMultipleSpotsType _type;
  final String? userID;
  late final String pageTitle;
  late final HSSpotsPage spotsPage;
  final _databaseRepository = app.databaseRepository;
  PagingController<int, HSSpot> get pagingController =>
      spotsPage.pagingController;

  Future<void> _init() async {
    try {
      emit(state.copyWith(status: HsMultipleSpotsStatus.loading));
      spotsPage = HSSpotsPage(fetchSpots: (batchSize, batchOffset) async {
        final spots =
            await _databaseRepository.spotfetchUserSpots(userID: userID);
        return spots;
      });
      await fetchUser();
      emit(state.copyWith(status: HsMultipleSpotsStatus.loaded));
    } catch (error) {
      HSDebugLogger.logError(error.toString());
      emit(state.copyWith(status: HsMultipleSpotsStatus.error));
    }
  }

  Future<void> fetchUser() async {
    try {
      final user = await _databaseRepository.userRead(userID: userID);
      emit(state.copyWith(user: user));
    } catch (error) {
      HSDebugLogger.logError(error.toString());
      throw Exception("Failed to fetch user.");
    }
  }

  @override
  Future<void> close() {
    spotsPage.dispose();
    return super.close();
  }
}
