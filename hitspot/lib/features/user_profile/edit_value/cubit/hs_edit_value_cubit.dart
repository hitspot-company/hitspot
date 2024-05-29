import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hitspot/app/hs_app.dart';
import 'package:hitspot/features/authentication/hs_authentication_bloc.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:hs_form_inputs/hs_form_inputs.dart';
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

  final HSDatabaseRepository _databaseRepository;
  final String? fieldName;
  final String field;
  final _app = HSApp.instance;

  Future<void> validateInput(String value, String fieldName) async {
    switch (fieldName) {
      case "username":
        if (!Username.usernameRegExp.hasMatch(value)) {
          throw Username.validateUsername(value);
        }
        if (!await _databaseRepository.userIsUsernameAvailable(value)) {
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

  Future<void> updateUser(HSUser user) async {
    emit(state.copyWith(status: HSEditValueStatus.loading));
    try {
      await validateInput(state.value, field);
      _databaseRepository.userUpdateField(user, field, state.value);
      await Future.delayed(const Duration(seconds: 1));
      _app.showToast(
        toastType: HSToastType.success,
        title: "Success",
        description: "The ${fieldName?.toLowerCase()} has been updated",
        alignment: Alignment.bottomCenter,
      );
      _app.authBloc
          .add(HSAppUserChanged(await _databaseRepository.userGet(user.uid!)));
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
