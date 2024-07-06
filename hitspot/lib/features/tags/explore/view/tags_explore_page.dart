import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/tags/explore/cubit/hs_tags_explore_cubit.dart';
import 'package:hitspot/widgets/form/hs_form.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/shimmers/hs_shimmer_box.dart';
import 'package:hitspot/widgets/spot/hs_better_spot_tile.dart';
import 'package:hs_database_repository/hs_database_repository.dart';

class TagsExplorePage extends StatelessWidget {
  const TagsExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final tagsExploreCubit = BlocProvider.of<HsTagsExploreCubit>(context);
    return HSScaffold(
      appBar: HSAppBar(enableDefaultBackButton: true),
      body: BlocSelector<HsTagsExploreCubit, HsTagsExploreState,
          HSTagsExploreStatus>(
        selector: (state) => state.status,
        builder: (context, state) {
          if (state == HSTagsExploreStatus.loadingSpots ||
              state == HSTagsExploreStatus.loadingTopSpot) {
            return const Center(child: CircularProgressIndicator());
          } else if (state == HSTagsExploreStatus.error) {
            return const Center(child: Text('Error fetching spot'));
          }
          final HSSpot topSpot = tagsExploreCubit.state.topSpot;
          final List<HSSpot> spots = tagsExploreCubit.state.spots;

          return ListView(
            shrinkWrap: true,
            children: [
              const Gap(16.0),
              HSBetterSpotTile(
                spot: topSpot,
                height: 140.0,
                borderRadius: BorderRadius.circular(14.0),
                child: Center(
                  child: Text(
                    "#${tagsExploreCubit.tag}",
                    style: textTheme.displayMedium,
                  ),
                ),
              ),
              const Gap(8.0),
              Text(
                "${topSpot.title} by @${topSpot.author?.name}",
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              // const Gap(16.0),
              // const HSFormHeadline(
              //   text: "Top Boards",
              //   headlineType: HSFormHeadlineType.display,
              // ),
              // const Gap(16.0),
              // SizedBox(
              //   height: 200.0,
              //   child: ListView.separated(
              //     separatorBuilder: (context, index) => const Gap(16.0),
              //     scrollDirection: Axis.horizontal,
              //     itemCount: 5,
              //     itemBuilder: (BuildContext context, int index) {
              //       return HSShimmerBox(width: 140.0, height: 100);
              //     },
              //   ),
              // ),
              const Gap(32.0),
              const HSFormHeadline(
                text: "Top Spots",
                headlineType: HSFormHeadlineType.display,
              ),
              const Gap(16.0),
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16.0,
                  crossAxisSpacing: 16.0,
                ),
                itemCount: spots.length,
                itemBuilder: (BuildContext context, int index) {
                  final spot = spots[index];
                  return HSBetterSpotTile(
                    spot: spot,
                    borderRadius: BorderRadius.circular(14.0),
                    onTap: (p0) => navi.toSpot(sid: p0!.sid!),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
