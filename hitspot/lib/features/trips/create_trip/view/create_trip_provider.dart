import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/features/trips/create_trip/cubit/hs_create_trip_cubit.dart';
import 'package:hitspot/features/trips/create_trip/view/create_trip_page.dart';

class CreateTripProvider extends StatelessWidget {
  const CreateTripProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HSCreateTripCubit(),
      child: const CreateTripPage(),
    );
  }
}
