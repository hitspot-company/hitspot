import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hitspot/app/hs_app.dart';
import 'package:hitspot/authentication/bloc/hs_authentication_bloc.dart';
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

  final HSDatabaseRepository _databaseRepository;
  final String? fieldName;
  final String field;
  final _app = HSApp.instance;

  void changeValue(String newValue) => emit(state.copyWith(
      value: newValue,
      status: newValue != state.initialValue
          ? HSEditValueStatus.idle
          : HSEditValueStatus.updated));

  Future<void> updateUser(HSUser user) async {
    emit(state.copyWith(status: HSEditValueStatus.loading));
    try {
      _databaseRepository.updateField(user, field, state.value);
      await Future.delayed(const Duration(seconds: 1));
      _app.showToast(
        toastType: HSToastType.success,
        title: "Success",
        description: "The ${fieldName?.toLowerCase()} has been updated",
        alignment: Alignment.bottomCenter,
      );
      _app.authBloc.add(HSAppUserChanged(
          await _databaseRepository.getUserFromDatabase(user.uid!)));
      emit(state.copyWith(status: HSEditValueStatus.updated));
      return;
    } catch (e) {
      // TODO: Add error handling
      HSDebugLogger.logError("Error changing value: $e");
    }
    emit(state.copyWith(status: HSEditValueStatus.idle));
  }
}
