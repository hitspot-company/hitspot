import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/authentication/bloc/hs_authentication_bloc.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';

class HSUserMonitor extends StatelessWidget {
  const HSUserMonitor({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<HSAuthenticationBloc, HSAuthenticationState, HSUser>(
      selector: (state) => state.user,
      builder: (context, state) => child,
    );
  }
}
