import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'hs_single_spot_state.dart';

class HSSingleSpotCubit extends Cubit<HsSingleSpotState> {
  HSSingleSpotCubit() : super(HsSingleSpotInitial());
}
