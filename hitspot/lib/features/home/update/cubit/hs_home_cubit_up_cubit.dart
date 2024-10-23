import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hitspot/wrappers/map/cubit/hs_map_wrapper_cubit.dart';

part 'hs_home_cubit_up_state.dart';

class HsHomeCubitUpCubit extends Cubit<HsHomeCubitUpState> {
  HsHomeCubitUpCubit(this.mapWrapper) : super(HsHomeCubitUpInitial());

  final HSMapWrapperCubit mapWrapper;
}
