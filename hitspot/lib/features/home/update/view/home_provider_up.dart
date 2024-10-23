import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/features/home/update/cubit/hs_home_cubit_up_cubit.dart';
import 'package:hitspot/features/home/update/view/home_page_up.dart';
import 'package:hitspot/wrappers/map/cubit/hs_map_wrapper_cubit.dart';

class HomeProviderUp extends StatelessWidget {
  const HomeProviderUp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => HSMapWrapperCubit(),
        ),
        BlocProvider(
            create: (context) =>
                HsHomeCubitUpCubit(context.read<HSMapWrapperCubit>())),
      ],
      child: const HomePageUp(),
    );
  }
}
