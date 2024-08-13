import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/tags/explore/cubit/hs_tags_explore_cubit.dart';
import 'package:hitspot/widgets/auth/hs_text_prompt.dart';
import 'package:hitspot/widgets/form/hs_form.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_button.dart';
import 'package:hitspot/widgets/hs_icon_prompt.dart';
import 'package:hitspot/widgets/hs_loading_indicator.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/spot/hs_better_spot_tile.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TagsExplorePage extends StatelessWidget {
  const TagsExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final tagsExploreCubit = BlocProvider.of<HSTagsExploreCubit>(context);
    return HSScaffold(
      appBar: HSAppBar(
        enableDefaultBackButton: true,
      ),
      body: BlocSelector<HSTagsExploreCubit, HSTagsExploreState,
          HSTagsExploreStatus>(
        selector: (state) => state.status,
        builder: (context, state) {
          if (state == HSTagsExploreStatus.loadingSpots ||
              state == HSTagsExploreStatus.loadingTopSpot) {
            return const Center(child: HSLoadingIndicator())
                .animate()
                .fadeIn(duration: 300.ms, curve: Curves.easeInOut);
          } else if (state == HSTagsExploreStatus.error) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const HSIconPrompt(
                  message: "No spots with this tag",
                  iconData: FontAwesomeIcons.xmark,
                ),
                const Gap(8.0),
                HSButton(onPressed: navi.pop, child: const Text("Back"))
              ],
            )
                .animate()
                .fadeIn(duration: 300.ms, curve: Curves.easeInOut)
                .slideY(begin: 0.2, end: 0);
          }

          final HSSpot topSpot = tagsExploreCubit.state.topSpot;
          final List<HSSpot> spots = tagsExploreCubit.state.spots;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Gap(16.0),
                    _AnimatedTopSpot(
                        topSpot: topSpot, tag: tagsExploreCubit.tag),
                    const Gap(32.0),
                    const HSFormHeadline(
                      text: "Top Spots",
                      headlineType: HSFormHeadlineType.display,
                    )
                        .animate()
                        .fadeIn(duration: 300.ms, delay: 200.ms)
                        .slideX(begin: -0.2, end: 0),
                    const Gap(16.0),
                  ],
                ),
              ),
              SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16.0,
                  crossAxisSpacing: 16.0,
                  childAspectRatio: 0.8,
                ),
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    final spot = spots[index];
                    return _AnimatedSpotTile(
                      spot: spot,
                      index: index,
                    );
                  },
                  childCount: spots.length,
                ),
              ),
              const SliverGap(32.0),
            ],
          );
        },
      ),
    );
  }
}

class _AnimatedTopSpot extends StatelessWidget {
  const _AnimatedTopSpot({
    required this.topSpot,
    required this.tag,
  });

  final HSSpot topSpot;
  final String tag;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HSBetterSpotTile(
          spot: topSpot,
          height: 200.0,
          borderRadius: BorderRadius.circular(16.0),
          child: Center(
            child: Text(
              "#$tag",
              style: textTheme.displayMedium?.copyWith(color: Colors.white),
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms, curve: Curves.easeInOut)
            .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
        const Gap(8.0),
        HSTextPrompt(
                prompt: "@${topSpot.author?.username}'s ",
                pressableText: topSpot.title!,
                promptColor: app.theme.mainColor,
                textStyle: textTheme.bodyMedium,
                onTap: () => navi.toSpot(sid: topSpot.sid!))
            .animate()
            .fadeIn(duration: 300.ms, delay: 200.ms)
            .slideY(begin: 0.2, end: 0),
      ],
    );
  }
}

class _AnimatedSpotTile extends StatelessWidget {
  const _AnimatedSpotTile({
    required this.spot,
    required this.index,
  });

  final HSSpot spot;
  final int index;

  @override
  Widget build(BuildContext context) {
    return HSBetterSpotTile(
      spot: spot,
      borderRadius: BorderRadius.circular(14.0),
      onTap: (p0) {
        HapticFeedback.lightImpact();
        navi.toSpot(sid: p0!.sid!);
      },
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: (200 + index * 50).ms)
        .slideY(begin: 0.2, end: 0)
        .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
  }
}
