import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/features/spots/create/create_spot_error_page.dart';
import 'package:hitspot/features/spots/create/location/cubit/hs_create_spot_location_cubit.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';
import 'package:hitspot/widgets/hs_loading_indicator.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';

class CreateSpotLocationPage extends StatelessWidget {
  const CreateSpotLocationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return HSScaffold(
      body: BlocSelector<HsCreateSpotLocationCubit, HsCreateSpotLocationState,
          HsCreateSpotLocationStatus>(
        selector: (state) => state.status,
        builder: (context, status) {
          if (status == HsCreateSpotLocationStatus.error) {
            return const CreateSpotErrorPage(HSCreateSpotErrorType.location);
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const HSLoadingIndicator(),
              const SizedBox(
                height: 16.0,
              ),
              Text("Fetching location...",
                  style: Theme.of(context).textTheme.titleMedium!.hintify),
            ],
          );
        },
      ),
    );
  }
}
