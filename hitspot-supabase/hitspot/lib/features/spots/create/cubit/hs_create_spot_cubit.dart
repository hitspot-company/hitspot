import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
// import 'package:hs_location_repository/hs_location_repository.dart';
import 'package:image_picker/image_picker.dart';

part 'hs_create_spot_state.dart';

class HSCreateSpotCubit extends Cubit<HSCreateSpotState> {
  HSCreateSpotCubit() : super(const HSCreateSpotState());
}
