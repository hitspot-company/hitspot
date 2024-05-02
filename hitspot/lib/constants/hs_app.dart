import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/authentication/bloc/hs_authentication_bloc.dart';
import 'package:hitspot/constants/hs_assets.dart';
import 'package:hitspot/constants/hs_theme.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';

class HSApp {
  static HSApp instance = HSApp();
  final HSTheme theme = HSTheme.instance;
  final HSAssets assets = HSAssets.instance;
}
