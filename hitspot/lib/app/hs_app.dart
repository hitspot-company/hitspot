import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/authentication/bloc/hs_authentication_bloc.dart';

class HSApp {
  static final HSApp instance = HSApp._internal();

  factory HSApp() => instance;

  HSApp._internal();

  String? get username =>
      BlocProvider.of<HSAuthenticationBloc>(navigator!.context)
          .state
          .user
          .username;
}
