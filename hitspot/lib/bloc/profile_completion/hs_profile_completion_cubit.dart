import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hitspot/constants/hs_app.dart';
import 'package:hitspot/models/hs_user.dart';
import 'package:hitspot/repositories/user/hs_user_repo.dart';

part 'hs_profile_completion_state.dart';

class HSProfileCompletionCubit extends Cubit<HSProfileCompletionState> {
  HSProfileCompletionCubit() : super(const HSProfileCompletionUpdate());

  void updateBirthdate(String newDate) => emit(state.copyWith(bday: newDate));

  void updateFullname(String newFullname) =>
      emit(state.copyWith(fullname: newFullname));

  void updateUsername(String newUsername) =>
      emit(state.copyWith(username: newUsername));

  void updatePreferences(List<Object?> newPreferences) {
    print("Current preferences: ${state.preferences}");
    emit(state.copyWith(preferences: newPreferences));
    print("New preferences: ${state.preferences}");
  }

  void changeStep(int newStep, [GlobalKey<FormState>? key]) {
    if (newStep == 5) {
      createUser();
    } else {
      emit(state.copyWith(step: newStep));
    }
  }

  Future<void> createUser() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      String? identityProviderID = currentUser?.uid;
      if (currentUser == null || identityProviderID == null) {
        throw "User is not signed in";
      }
      HSUser localUser = HSUser(
        email: currentUser.email,
        username: state.username,
        fullName: state.fullname,
        tags: state.preferences,
        birthday: Timestamp.fromDate(DateTime.parse(state.bday)),
      );
      HSUser createdUser =
          await HSUserRepo().createUser(localUser, identityProviderID);
      print(createdUser.toString());
      // TODO: Navigate to home screen
    } catch (e) {
      print("Error creating user account: $e");
    }
  }
}
