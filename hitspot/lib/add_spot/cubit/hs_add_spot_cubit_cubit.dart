import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';

part 'hs_add_spot_cubit_state.dart';

class HSAddSpotCubit extends Cubit<HSAddSpotCubitState> {
  final HSDatabaseRepository _hsDatabaseRepository;

  HSAddSpotCubit(this._hsDatabaseRepository) : super(HsAddSpotCubitInitial());

  Future<void> createSpot() async {
    HSDebugLogger.logInfo("Creating spot");
    await _hsDatabaseRepository.createSpot(
      title: state.title,
    );
  }

  void titleChanged({required String title}) {
    emit(
      state.copyWith(title: title),
    );
  }
}
