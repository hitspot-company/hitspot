import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/features/spots/multiple/cubit/hs_multiple_spots_cubit.dart';
import 'package:hitspot/features/spots/multiple/view/multiple_spots_page.dart';

class MultipleSpotsProvider extends StatelessWidget {
  const MultipleSpotsProvider(
      {super.key, this.type = HSMultipleSpotsType.userSpots, this.userID});

  final HSMultipleSpotsType type;
  final String? userID;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HsMultipleSpotsCubit(type, userID: userID),
      child: const MultipleSpotsPage(),
    );
  }
}
