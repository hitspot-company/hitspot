import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/features/map/main/cubit/hs_map_cubit.dart';
import 'package:hitspot/features/map/main/view/map_page.dart';
import 'package:hitspot/features/map/search/cubit/hs_map_search_cubit.dart';
import 'package:hs_location_repository/hs_location_repository.dart';

class MapProvider extends StatelessWidget {
  const MapProvider({super.key, this.initialCameraPosition});

  final Position? initialCameraPosition;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => HSMapCubit(initialCameraPosition),
        ),
        BlocProvider(
          create: (context) => HSMapSearchCubit(),
        ),
      ],
      child: const MapPage(),
    );
  }
}
