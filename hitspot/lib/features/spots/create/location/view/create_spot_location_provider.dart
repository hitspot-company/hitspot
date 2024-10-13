import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/features/spots/create/location/cubit/hs_create_spot_location_cubit.dart';
import 'package:hitspot/features/spots/create/location/view/create_spot_location_page.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:image_picker/image_picker.dart';

class CreateSpotLocationProvider extends StatelessWidget {
  const CreateSpotLocationProvider(
      {super.key, required this.images, this.prototype});

  final List<XFile> images;
  final HSSpot? prototype;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          HsCreateSpotLocationCubit(images: images, prototype: prototype),
      child: const CreateSpotLocationPage(),
    );
  }
}
