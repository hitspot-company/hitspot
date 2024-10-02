import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';

part 'hs_user_profile_multiple_state.dart';

class HsUserProfileMultipleCubit extends Cubit<HsUserProfileMultipleState> {
  HsUserProfileMultipleCubit(this.type, this.userID, this.spotID, this.boardID)
      : super(const HsUserProfileMultipleState());

  final HSUserProfileMultipleType type;
  final String? userID;
  final String? spotID;
  final String? boardID;

  void fetchUsers() {
    emit(state.copyWith(status: HSUserProfileMultipleStatus.loading));
    try {
      final users = <HSUser>[];
      switch (type) {
        case HSUserProfileMultipleType.follows:
          users.addAll(HSUser.fakeUsers);
          break;
        case HSUserProfileMultipleType.likes:
          users.addAll(HSUser.fakeUsers);
          break;
        case HSUserProfileMultipleType.collaborators:
          users.addAll(HSUser.fakeUsers);
          break;
      }
      emit(state.copyWith(
          status: HSUserProfileMultipleStatus.loaded, users: users));
    } catch (e) {
      emit(state.copyWith(status: HSUserProfileMultipleStatus.error));
    }
  }
}
