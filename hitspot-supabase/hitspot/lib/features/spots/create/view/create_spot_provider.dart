import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/features/spots/create/cubit/hs_create_spot_cubit.dart';
import 'package:hitspot/features/spots/create/view/create_spot_page.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';

class CreateSpotProvider extends StatelessWidget {
  const CreateSpotProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HSCreateSpotCubit(),
      child: const CreateSpotPage(),
    );
  }
}
