import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hs_form_inputs/hs_form_inputs.dart';

part 'hs_complete_profile_state.dart';

class HsCompleteProfileCubit extends Cubit<HSCompleteProfileState> {
  HsCompleteProfileCubit() : super(const HSCompleteProfileState());

  void updateBirthday() async {
    final DateTime? dateTime = await app.pickers.date(
      lastDate: app.pickers.minAge,
      firstDate: app.pickers.maxAge,
      currentDate: app.pickers.minAge,
    );
    if (dateTime != null) {
      emit(
        state.copyWith(
          birthday: Birthdate.dirty(dateTime.toString()),
          error: "",
        ),
      );
    }
  }
}
