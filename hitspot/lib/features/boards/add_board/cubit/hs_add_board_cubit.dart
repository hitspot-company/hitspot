import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'hs_add_board_state.dart';

class HSAddBoardCubit extends Cubit<HSAddBoardState> {
  HSAddBoardCubit() : super(HSAddBoardState());

  void updateTitle(String value) => emit(state.copyWith(title: value));
  void updateDescription(String value) =>
      emit(state.copyWith(description: value));

  void nextPage() => state.pageController.nextPage(
      duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
  void prevPage() => state.pageController.previousPage(
      duration: const Duration(milliseconds: 200), curve: Curves.easeIn);

  @override
  Future<void> close() {
    state.pageController.dispose();
    return super.close();
  }
}
