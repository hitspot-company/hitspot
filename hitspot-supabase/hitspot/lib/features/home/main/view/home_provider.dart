import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/features/home/main/cubit/hs_home_cubit.dart';
import 'package:hitspot/features/home/main/view/home_page.dart';

class HomeProvider extends StatelessWidget {
  const HomeProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HSHomeCubit(),
      child: const HomePage(),
    );
  }
}
