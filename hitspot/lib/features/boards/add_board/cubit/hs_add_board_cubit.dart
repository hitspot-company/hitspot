import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'hs_add_board_state.dart';

class HsAddBoardCubit extends Cubit<HsAddBoardState> {
  HsAddBoardCubit() : super(HsAddBoardInitial());
}
