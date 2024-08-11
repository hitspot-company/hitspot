import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/utils/forms/hs_username.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:hs_toasts/hs_toasts.dart';

part 'hs_edit_value_state.dart';

class HSEditValueCubit extends Cubit<HSEditValueState> {
  HSEditValueCubit(
    this._databaseRepository, {
    this.fieldName,
    required this.field,
    String? fieldDescription,
    String? initialValue,
  }) : super(
          HSEditValueState(
            fieldName: fieldName,
            fieldDescription: fieldDescription,
            value: initialValue ?? "",
            initialValue: initialValue ?? "",
          ),
        );

  final HSDatabaseRepsitory _databaseRepository;
  final String? fieldName;
  final String field;

  Future<void> validateInput(String value, String fieldName) async {
    switch (fieldName) {
      case "username":
        if (!HSUsername.usernameRegExp.hasMatch(value)) {
          throw HSUsername.validateUsername(value);
        }
        if (!await _databaseRepository.userIsUsernameAvailable(
            username: value)) {
          throw "The username is not available.";
        }
      case "full_name":
        if (!value.isNotEmpty) {
          throw "The name cannot be empty";
        }
    }
  }

  void changeValue(String newValue) => emit(state.copyWith(
        value: newValue,
        status: newValue != state.initialValue
            ? HSEditValueStatus.idle
            : HSEditValueStatus.updated,
        errorText: null,
      ));

  HSUser getUpdatedUser(HSUser user) {
    switch (field) {
      case "username":
        return user.copyWith(username: state.value);
      case "name":
        return user.copyWith(fullName: state.value);
      case "biogram":
        return user.copyWith(biogram: state.value);
      default:
        return user;
    }
  }

  Future<void> updateUser() async {
    emit(state.copyWith(status: HSEditValueStatus.loading));
    try {
      final user = getUpdatedUser(currentUser);
      await validateInput(state.value, field);
      await _databaseRepository.userUpdate(user: user);
      app.showToast(
        toastType: HSToastType.success,
        title: "Success",
        description: "The ${fieldName?.toLowerCase()} has been updated",
        alignment: Alignment.bottomCenter,
      );
      app.authenticationBloc.userChangedEvent(
          user: await _databaseRepository.userRead(user: user));
      emit(state.copyWith(status: HSEditValueStatus.updated));
      HSScaffold.hideInput();
      return;
    } catch (e) {
      HSDebugLogger.logError("Error changing value: $e");
      emit(state.copyWith(errorText: e.toString()));
    }
    emit(state.copyWith(
        status: HSEditValueStatus.idle, errorText: state.errorText));
  }
}
