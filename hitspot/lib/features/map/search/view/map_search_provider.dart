import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/features/map/search/cubit/hs_map_search_cubit.dart';

class MapSearchProvider extends StatelessWidget {
  const MapSearchProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => HSMapSearchCubit(), child: Container());
  }
}
