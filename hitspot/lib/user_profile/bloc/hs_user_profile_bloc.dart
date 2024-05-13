import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:hitspot/app/hs_app.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';

part 'hs_user_profile_event.dart';
part 'hs_user_profile_state.dart';

class HSUserProfileBloc extends Bloc<HSUserProfileEvent, HSUserProfileState> {
  HSUserProfileBloc({
    required this.databaseRepository,
    required this.userID,
  }) : super(HSUserProfileInitialLoading()) {
    on<HSUserProfileInitialEvent>((event, emit) async {
      await Future.delayed(const Duration(milliseconds: 100));
      await _getUserData(event, emit);
    });
  }

  final String userID;
  final HSDatabaseRepository databaseRepository;
  late final HSUser? userData;
  final ScrollController scrollController = ScrollController();

  Future<void> _getUserData(event, emit) async {
    emit(HSUserProfileInitialLoading());
    try {
      userData = await databaseRepository.getUserFromDatabase(userID);
      emit(HSUserProfileReady(userData));
    } on DatabaseConnectionFailure catch (e) {
      emit(HSUserProfileError(e.message));
    } catch (e) {
      emit(const HSUserProfileError("An unknown error occured"));
    }
  }
}
