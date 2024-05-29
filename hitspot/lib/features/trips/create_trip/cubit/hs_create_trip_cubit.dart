import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:hs_form_inputs/hs_form_inputs.dart';

part 'hs_create_trip_state.dart';

class HSCreateTripCubit extends Cubit<HSCreateTripState> {
  HSCreateTripCubit({this.board, this.prototype})
      : super(prototype != null
            ? HSCreateTripState.update(prototype)
            : const HSCreateTripState());

  final PageController pageController = PageController();
  final HSTrip? prototype;
  final HSBoard? board;
  final HSDatabaseRepository _databaseRepository = app.databaseRepository;

  void updateTitle(String val) => emit(state.copyWith(tripTitle: val.trim()));
  void updateDescription(String val) =>
      emit(state.copyWith(tripDescription: val.trim()));
  void updateBudget(double val) => emit(state.copyWith(tripBudget: val));
  void updateVisibility(HSTripVisibility? tripVisibility) =>
      emit(state.copyWith(tripVisibility: tripVisibility));

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

  void changeTripDate() async {
    DateTime now = DateTime.now();
    DateTime? pickedDate = await showDatePicker(
        context: app.context!,
        currentDate:
            state.tripDate.isNotEmpty ? state.tripDate.stringToDateTime() : now,
        firstDate: now,
        lastDate: DateTime(now.year + 50, now.month, now.day));
    if (pickedDate != null) {
      emit(state.copyWith(tripDate: pickedDate.toString()));
    }
  }

  Future<void> _createTrip() async {
    try {
      final Timestamp? tripDate = state.tripDate.isNotEmpty
          ? state.tripDate.dateTimeStringToTimestamp()
          : null;
      final HSTrip trip = HSTrip(
        participants: [],
        editors: [],
        tripBudget: state.tripBudget,
        date: tripDate,
        authorID: currentUser.uid,
        description: state.tripDescription,
        title: state.tripTitle,
        tripVisibility: state.tripVisibility,
        createdAt: Timestamp.now(),
      );
      final String tripID = await _databaseRepository.tripCreate(trip);
      await Future.delayed(const Duration(seconds: 1));
      navi.router.go("/trip/$tripID");
    } on DatabaseConnectionFailure catch (_) {
      HSDebugLogger.logError("Error creating trip: ${_.message}");
      emit(state.copyWith(createTripStatus: HSCreateTripStatus.error));
    } catch (_) {
      HSDebugLogger.logError("Unknown error: $_");
      emit(state.copyWith(createTripStatus: HSCreateTripStatus.error));
    }
  }

  Future<void> _updateTrip() async {
    try {
      final HSTrip trip = prototype!.copyWith(
        participants: [],
        editors: [],
        tripBudget: state.tripBudget,
        tripDate: state.tripDate.dateTimeStringToTimestamp(),
        description: state.tripDescription,
        title: state.tripTitle,
        tripVisibility: state.tripVisibility,
      );
      await _databaseRepository.tripUpdate(trip);
      navi.router.go("/trip/${trip.tid}");
    } on DatabaseConnectionFailure catch (_) {
      HSDebugLogger.logError("Error creating board: ${_.message}");
      emit(state.copyWith(createTripStatus: HSCreateTripStatus.error));
    } catch (_) {
      HSDebugLogger.logError("Unknown error: $_");
      emit(state.copyWith(createTripStatus: HSCreateTripStatus.error));
    }
  }

  Future<void> submit() async {
    emit(state.copyWith(createTripStatus: HSCreateTripStatus.uploading));
    try {
      if (prototype == null) {
        await _createTrip();
        HSDebugLogger.logSuccess("Trip Created");
      } else {
        await _updateTrip();
        HSDebugLogger.logSuccess("Trip Updated");
      }
    } on DatabaseConnectionFailure catch (_) {
    } catch (_) {}
  }

  @override
  Future<void> close() {
    pageController.dispose();
    return super.close();
  }
}
