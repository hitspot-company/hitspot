import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/extensions/hs_sliver_extensions.dart';
import 'package:hitspot/features/boards/single/view/single_board_page.dart';
import 'package:hitspot/features/spots/single/cubit/hs_single_spot_cubit.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_image.dart';
import 'package:hitspot/widgets/hs_loading_indicator.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/hs_user_tile.dart';

class SingleSpotPage extends StatelessWidget {
  const SingleSpotPage({super.key});

  @override
  Widget build(BuildContext context) {
    final singleSpotCubit = BlocProvider.of<HSSingleSpotCubit>(context);
    return HSScaffold(
      appBar: HSAppBar(
        enableDefaultBackButton: true,
      ),
      body: BlocBuilder<HSSingleSpotCubit, HsSingleSpotState>(
        buildWhen: (previous, current) =>
            previous.status != current.status || previous.spot != current.spot,
        builder: (context, state) {
          final status = state.status;
          if (status == HSSingleSpotStatus.loading) {
            return const HSLoadingIndicator();
          } else if (status == HSSingleSpotStatus.error) {
            return const Center(child: Text('Error fetching spot'));
          }
          final spot = singleSpotCubit.state.spot;
          final imagesCount = spot.images?.length ?? 0;
          return CustomScrollView(
            slivers: [
              Text(
                "${spot.title}",
                style: textTheme.displayMedium,
              ).toSliver,
              const Gap(24.0).toSliver,
              HSImage(
                imageUrl: spot.images?.first,
                height: 300.0,
                width: screenWidth,
                borderRadius: BorderRadius.circular(16.0),
              ).toSliver,
              const Gap(16.0).toSliver,
              AutoSizeText(
                "${spot.address}",
                style: textTheme.displaySmall!.hintify,
                maxLines: 2,
              ).toSliver,
              const Gap(32.0).toSliver,
              Text(
                spot.description!,
                style: textTheme.headlineMedium,
              ).toSliver,
              const Gap(32.0).toSliver,
              Row(
                children: [
                  HsUserTile(
                    user: spot.author!,
                  ),
                  const Expanded(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Icon(FontAwesomeIcons.heart),
                      Icon(FontAwesomeIcons.comment),
                      Icon(FontAwesomeIcons.bookmark),
                    ],
                  )),
                ],
              ).toSliver,
              const Gap(32.0).toSliver,
              SliverList.separated(
                itemCount: imagesCount - 1,
                separatorBuilder: (context, index) => const Gap(16.0),
                itemBuilder: (context, index) => HSImage(
                  imageUrl: spot.images?[index + 1],
                  height: 300.0,
                  width: screenWidth,
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
              const Gap(32.0).toSliver,
            ],
          );
        },
      ),
    );
  }
}
