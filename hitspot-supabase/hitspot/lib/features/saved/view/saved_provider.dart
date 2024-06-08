import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/features/saved/cubit/hs_saved_cubit.dart';
import 'package:hitspot/features/saved/view/saved_page.dart';

class SavedProvider extends StatelessWidget {
  const SavedProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HSSavedCubit(),
      child: const SavedPage(),
    );
  }
}
