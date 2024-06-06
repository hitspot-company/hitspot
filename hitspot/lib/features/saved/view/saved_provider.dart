import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/features/saved/bloc/hs_saved_bloc.dart';
import 'package:hitspot/features/saved/view/saved_page.dart';

class SavedProvider extends StatelessWidget {
  const SavedProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HSSavedBloc()..add(HSSavedFetchInitial()),
      child: const SavedPage(),
    );
  }
}
