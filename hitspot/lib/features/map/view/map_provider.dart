import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/features/map/cubit/hs_map_cubit.dart';
import 'package:hitspot/features/map/view/map_page.dart';
import 'package:hs_location_repository/hs_location_repository.dart';

class MapProvider extends StatelessWidget {
  const MapProvider({super.key, this.initialCameraPosition});

  final Position? initialCameraPosition;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => HSMapCubit(initialCameraPosition),
        child: const MapPage());
  }
}
