import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/features/spots/create/choose_location/cubit/hs_choose_location_cubit.dart';
import 'package:hitspot/features/spots/create/choose_location/view/choose_location_page.dart';
import 'package:hs_location_repository/hs_location_repository.dart';

class ChooseLocationProvider extends StatelessWidget {
  const ChooseLocationProvider({super.key, required this.initialUserLocation});

  final Position initialUserLocation;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HsChooseLocationCubit(initialUserLocation),
      child: const ChooseLocationPage(),
    );
  }
}
