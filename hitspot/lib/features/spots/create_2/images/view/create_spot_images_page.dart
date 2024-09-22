import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/features/spots/create/view/create_spot_error_page.dart';
import 'package:hitspot/features/spots/create_2/create_spot_error_page.dart';
import 'package:hitspot/features/spots/create_2/images/cubit/hs_create_spot_images_cubit.dart';
import 'package:hitspot/widgets/hs_loading_indicator.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';

class CreateSpotImagesPage extends StatelessWidget {
  const CreateSpotImagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return HSScaffold(
      body: BlocSelector<HsCreateSpotImagesCubit, HsCreateSpotImagesState,
          HsCreateSpotImagesStatus>(
        selector: (state) => state.status,
        builder: (context, status) {
          if (status == HsCreateSpotImagesStatus.error) {
            return const CreateSpotErrorPage(HSCreateSpotErrorType.photos);
          }
          return const HSLoadingIndicator();
        },
      ),
    );
  }
}
