import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/add_spot/cubit/hs_add_spot_cubit_cubit.dart';
import 'package:hitspot/add_spot/view/add_spot_form.dart';
import 'package:hitspot/app/hs_app.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';

class AddSpotPage extends StatelessWidget {
  const AddSpotPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const AddSpotPage());
  }

  @override
  Widget build(BuildContext context) {
    return HSScaffold(
      resizeToAvoidBottomInset: false,
      sidePadding: 24.0,
      body: BlocProvider(
        create: (_) => HSAddSpotCubit(HSApp.instance.databaseRepository),
        child: const AddSpotForm(),
      ),
    );
  }
}
