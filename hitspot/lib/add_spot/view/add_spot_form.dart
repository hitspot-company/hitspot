import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/add_spot/cubit/hs_add_spot_cubit_cubit.dart';
import 'package:hitspot/app/hs_app.dart';

class AddSpotForm extends StatelessWidget {
  const AddSpotForm({super.key});

  @override
  Widget build(BuildContext context) {
    final hsApp = HSApp.instance;
    final hsNavigation = hsApp.navigation;
    final addSpotCubit = context.read<HSAddSpotCubit>();

    return Form(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TextFormField(
          decoration: InputDecoration(labelText: 'Title'),
          onChanged: (value) => addSpotCubit.titleChanged(title: value),
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            addSpotCubit.createSpot();
          },
          child: Text('Submit'),
        ),
      ],
    ));
  }
}
