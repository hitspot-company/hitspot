import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/home/main/view/home_page.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';

part 'hs_multiple_spots_state.dart';

class HsMultipleSpotsCubit extends Cubit<HsMultipleSpotsState> {
  HsMultipleSpotsCubit(this._type, {this.userID})
      : super(HsMultipleSpotsState(type: _type)) {
    _init();
  }

  final HSMultipleSpotsType _type;
  final String? userID;
  late final HSHitsPage hitsPage;
  final _databaseRepository = app.databaseRepository;
  PagingController<int, dynamic> get pagingController =>
      hitsPage.pagingController;

  String get pageTitle {
    switch (_type) {
      case HSMultipleSpotsType.trendingBoards:
        return "Trending boards";
      case HSMultipleSpotsType.nearbySpots:
        return "Nearby spots";
      case HSMultipleSpotsType.trendingSpots:
        return "Trending spots";
      case HSMultipleSpotsType.userSpots:
        return "@username spots"; // TODO: change this
    }
  }

  HSHitsPage get _hitsPage {
    switch (_type) {
      case HSMultipleSpotsType.trendingBoards:
        return HSHitsPage(
            pageSize: 10,
            fetch: _fetchTrendingBoards,
            type: HSHitsPageType.boards);
      case HSMultipleSpotsType.nearbySpots:
        return HSHitsPage(
            pageSize: 10, fetch: _fetchNearbySpots, type: HSHitsPageType.spots);
      default:
        return HSHitsPage(pageSize: 10, fetch: _fetchTrendingSpots);
    }
  }

  Future<void> _init() async {
    try {
      emit(state.copyWith(status: HsMultipleSpotsStatus.loading));
      hitsPage = _hitsPage;
      emit(state.copyWith(status: HsMultipleSpotsStatus.loaded));
    } catch (error) {
      HSDebugLogger.logError(error.toString());
      emit(state.copyWith(status: HsMultipleSpotsStatus.error));
    }
  }

  Future<List<HSSpot>> _fetchTrendingSpots(int size, int offset) async {
    try {
      List<HSSpot> spots = await _databaseRepository.spotFetchTrendingSpots(
          batchSize: size, batchOffset: offset);
      return (spots);
    } catch (e) {
      HSDebugLogger.logError("Error fetching trending spots: $e");
      return [];
    }
  }

  Future<List<HSSpot>> _fetchNearbySpots(int size, int offset) async {
    try {
      assert(
          app.currentPosition != null, "The current position cannot be null");
      const double maxDistance = 300; // 300 km (TODO: Find a dynamic way)
      final List<HSSpot> spots = await _databaseRepository.spotFetchClosest(
        lat: app.currentPosition!.latitude,
        long: app.currentPosition!.longitude,
        batchSize: size,
        batchOffset: offset,
        distance: maxDistance,
      );
      return (spots);
    } catch (e) {
      HSDebugLogger.logError("Error fetching trending spots: $e");
      return [];
    }
  }

  Future<List<HSBoard>> _fetchTrendingBoards(int size, int offset) async {
    try {
      List<HSBoard> boards = await _databaseRepository.boardFetchTrendingBoards(
          batchOffset: offset, batchSize: size);
      return (boards);
    } catch (e) {
      HSDebugLogger.logError("Error fetching trending spots: $e");
      return [];
    }
  }

  @override
  Future<void> close() {
    hitsPage.dispose();
    return super.close();
  }
}
