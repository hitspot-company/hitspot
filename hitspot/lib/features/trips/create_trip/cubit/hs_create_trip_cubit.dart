import 'package:bloc/bloc.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';

part 'hs_create_trip_state.dart';

class HSCreateTripCubit extends Cubit<HSCreateTripState> {
  HSCreateTripCubit({this.board, this.prototype})
      : super(prototype != null
            ? HSCreateTripState.update(prototype)
            : const HSCreateTripState());

  final PageController pageController = PageController();
  final HSTrip? prototype;
  final HSBoard? board;

  void updateTitle(String val) => emit(state.copyWith(tripTitle: val));
  void updateDescription(String val) =>
      emit(state.copyWith(tripDescription: val));
  void back() => pageController.previousPage(
      duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
  void next() => pageController.nextPage(
      duration: const Duration(milliseconds: 200), curve: Curves.easeIn);

  void changeCurrency() => showCurrencyPicker(
        context: app.context!,
        showFlag: true,
        showCurrencyName: true,
        showCurrencyCode: true,
        theme: CurrencyPickerThemeData(backgroundColor: Colors.black),
        onSelect: (Currency currency) {
          emit(state.copyWith(currency: currency));
        },
      );
}
