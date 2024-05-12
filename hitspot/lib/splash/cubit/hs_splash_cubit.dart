import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'hs_splash_state.dart';

class HSSplashCubit extends Cubit<HSSplashState> {
  HSSplashCubit() : super(HSSplashInitial());

  // final AnimationController controller = AnimationController(vsync: this);
}
