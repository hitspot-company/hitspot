import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_location_repository/hs_location_repository.dart';

part 'hs_single_board_map_state.dart';

class HSSingleBoardMapCubit extends Cubit<HSSingleBoardMapState> {
  HSSingleBoardMapCubit(this._spots) : super(const HSSingleBoardMapState());

  final List<HSSpot> _spots;
  final _locationRepository = app.locationRepository;

  Future<void> loadCurrentPosition() async {
    final position = await _locationRepository.getCurrentLocation();
    emit(state.copyWith(currentPosition: position));
  }
}
