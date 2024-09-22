import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/features/spots/create_2/images/cubit/hs_create_spot_images_cubit.dart';
import 'package:hitspot/features/spots/create_2/images/view/create_spot_images_page.dart';
import 'package:hs_database_repository/hs_database_repository.dart';

class CreateSpotImagesProvider extends StatelessWidget {
  const CreateSpotImagesProvider({super.key, this.prototype});

  final HSSpot? prototype;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HsCreateSpotImagesCubit(prototype: prototype),
      child: const CreateSpotImagesPage(),
    );
  }
}
