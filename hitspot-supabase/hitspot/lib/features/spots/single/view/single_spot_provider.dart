import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/features/spots/single/cubit/hs_single_spot_cubit.dart';
import 'package:hitspot/features/spots/single/view/single_spot_page.dart';

class SingleSpotProvider extends StatelessWidget {
  const SingleSpotProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HSSingleSpotCubit(),
      child: const SingleSpotPage(),
    );
  }
}
