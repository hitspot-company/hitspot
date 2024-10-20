import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/features/map/cluster/cubit/hs_cluster_map_cubit.dart';
import 'package:hitspot/features/map/cluster/view/cluster_map_page.dart';
import 'package:hitspot/wrappers/map/cubit/hs_map_wrapper_cubit.dart';

class ClusterMapProvider extends StatelessWidget {
  const ClusterMapProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => HSMapWrapperCubit(),
        ),
        BlocProvider(
          create: (context) =>
              HSClusterMapCubit(context.read<HSMapWrapperCubit>()),
        ),
      ],
      child: const ClusterMapPage(),
    );
  }
}
