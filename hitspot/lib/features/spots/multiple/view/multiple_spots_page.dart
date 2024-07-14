import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/spots/multiple/cubit/hs_multiple_spots_cubit.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_loading_indicator.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/spot/hs_animated_spot_tile.dart';
import 'package:hs_database_repository/hs_database_repository.dart';

class MultipleSpotsPage extends StatelessWidget {
  const MultipleSpotsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<HsMultipleSpotsCubit>(context);
    return HSScaffold(
      appBar: HSAppBar(
        titleText: cubit.pageTitle,
        enableDefaultBackButton: true,
      ),
      body: BlocSelector<HsMultipleSpotsCubit, HsMultipleSpotsState,
          HsMultipleSpotsStatus>(
        selector: (state) => state.status,
        builder: (context, state) {
          if (state == HsMultipleSpotsStatus.loading) {
            return const HSLoadingIndicator();
          } else if (state == HsMultipleSpotsStatus.error) {
            return const Center(child: Text('Failed to load spots.'));
          }
          return PagedListView<int, HSSpot>(
            pagingController: cubit.pagingController,
            builderDelegate: PagedChildBuilderDelegate<HSSpot>(
              itemBuilder: (context, item, index) => SizedBox(
                height: 100,
                width: screenWidth,
                child: AnimatedSpotTile(spot: item, index: index),
              ),
            ),
          );
        },
      ),
    );
  }
}
