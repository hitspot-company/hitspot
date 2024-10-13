import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/features/spots/create/form/cubit/hs_create_spot_form_cubit.dart';
import 'package:hitspot/features/spots/create/form/view/create_spot_form_page.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_location_repository/hs_location_repository.dart';
import 'package:image_picker/image_picker.dart';

class CreateSpotFormProvider extends StatelessWidget {
  const CreateSpotFormProvider(
      {super.key,
      this.prototype,
      required this.images,
      required this.location});

  final HSSpot? prototype;
  final List<XFile> images;
  final HSLocation location;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HsCreateSpotFormCubit(
        images: images,
        location: location,
        prototype: prototype,
      ),
      child: const CreateSpotFormPage(),
    );
  }
}
