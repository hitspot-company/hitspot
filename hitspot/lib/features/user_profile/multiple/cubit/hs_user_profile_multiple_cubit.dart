import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'hs_user_profile_multiple_state.dart';

class HsUserProfileMultipleCubit extends Cubit<HsUserProfileMultipleState> {
  HsUserProfileMultipleCubit() : super(HsUserProfileMultipleInitial());
}
