import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/app/hs_app.dart';
import 'package:hitspot/features/user_profile/edit_profile/edit_value/cubit/hs_edit_value_cubit.dart';
import 'package:hitspot/features/user_profile/edit_profile/edit_value/view/edit_value_page.dart';

class EditValueProvider extends StatelessWidget {
  const EditValueProvider(
      {super.key,
      this.fieldDescription,
      this.fieldName,
      this.initialValue,
      required this.field});

  final String? fieldName;
  final String? fieldDescription;
  final String? initialValue;
  final String field;

  static Route<void> route(
      {String? fieldName,
      String? fieldDescription,
      String? initialValue,
      required String field}) {
    return MaterialPageRoute<void>(
      builder: (_) => EditValueProvider(
        fieldDescription: fieldDescription,
        fieldName: fieldName,
        initialValue: initialValue,
        field: field,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HSEditValueCubit(
        HSApp.instance.databaseRepository,
        field: field,
        fieldDescription: fieldDescription,
        fieldName: fieldName,
        initialValue: initialValue,
      ),
      child: const EditValuePage(),
    );
  }
}
