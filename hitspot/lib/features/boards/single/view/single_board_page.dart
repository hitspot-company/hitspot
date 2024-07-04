import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/extensions/hs_sliver_extensions.dart';
import 'package:hitspot/features/boards/create/view/create_board_provider.dart';
import 'package:hitspot/features/boards/single/cubit/hs_single_board_cubit.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_button.dart';
import 'package:hitspot/widgets/hs_image.dart';
import 'package:hitspot/widgets/hs_loading_indicator.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/hs_spot_tile.dart';
import 'package:hitspot/widgets/hs_spots_grid.dart';
import 'package:hitspot/widgets/hs_user_avatar.dart';
import 'package:hitspot/widgets/shimmers/hs_shimmer_box.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:reorderable_grid/reorderable_grid.dart';

class SingleBoardPage extends StatelessWidget {
  SingleBoardPage({super.key});

  ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    final singleBoardCubit = BlocProvider.of<HSSingleBoardCubit>(context);
    return BlocBuilder<HSSingleBoardCubit, HSSingleBoardState>(
      buildWhen: (previous, current) =>
          previous.status != current.status || previous.spots != current.spots,
      builder: (context, state) {
        final bool isLoading = state.status == HSSingleBoardStatus.loading;
        final HSUser? author = state.author;
        final HSBoard? board = state.board;
        final List<HSSpot> spots = state.spots;
        HSDebugLogger.logInfo("Updated, spots_count: ${spots.length}");
        return HSScaffold(
          appBar: HSAppBar(
            enableDefaultBackButton: true,
            titleText: state.board?.title ?? "",
            right: IconButton(
              onPressed: () => HSDebugLogger.logInfo("More"),
              icon: const Icon(
                FontAwesomeIcons.ellipsisVertical,
              ),
            ),
          ),
          floatingActionButton: HSButton.icon(
            label: Text("Create Trip",
                style: textTheme.headlineMedium!.colorify(appTheme.mainColor)),
            icon: const Icon(FontAwesomeIcons.mapPin),
            onPressed: () => HSDebugLogger.logInfo("Creating trip!"),
          ),
          body: CustomScrollView(
            controller: _scrollController,
            slivers: [
              if (board?.image != null)
                HSSimpleSliverAppBar(
                  height: 120,
                  child: HSImage(
                    borderRadius: BorderRadius.circular(14.0),
                    imageUrl: singleBoardCubit.state.board?.image,
                    color: board?.color,
                  ),
                ),
              const SliverToBoxAdapter(child: Gap(16.0)),
              HSSimpleSliverAppBar(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        HSUserAvatar(radius: 24.0, imageUrl: author?.avatarUrl),
                        const Gap(16.0),
                        if (isLoading)
                          const HSShimmerBox(width: 120, height: 30.0)
                        else
                          Text(
                            author?.username ?? "",
                            style: textTheme.headlineLarge,
                          ),
                        const Spacer(),
                        if (isLoading)
                          const HSShimmerBox(width: 120, height: 30.0)
                        else
                          _SaveActionButton(
                            status: state.status,
                            singleBoardCubit: singleBoardCubit,
                          ),
                        IconButton(
                          onPressed: () => HSDebugLogger.logInfo("Share"),
                          icon: const Icon(
                            FontAwesomeIcons.arrowUpRightFromSquare,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Gap(24.0).toSliver,
              if (isLoading)
                const HSShimmerBox(width: 60, height: 70.0).toSliverBox
              else
                SliverMainAxisGroup(
                  slivers: [
                    Text("Description", style: textTheme.headlineSmall)
                        .toSliver,
                    Text("${board?.description}",
                            style: textTheme.bodyMedium!.hintify)
                        .toSliver,
                  ],
                ),
              const Gap(24.0).toSliver,
              SliverToBoxAdapter(
                child: ReorderableListView.builder(
                  scrollController: _scrollController,
                  shrinkWrap: true,
                  itemCount: spots.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      key: ValueKey(index),
                      child: HSSpotTile(
                        onLongPress: singleBoardCubit.onLongPress,
                        index: index,
                        spot: spots[index],
                        extent: (index % 3 + 2) * 70.0 + 70.0,
                      ),
                    );
                  },
                  onReorder: (int oldIndex, int newIndex) {
                    singleBoardCubit.reorderSpots(spots, oldIndex, newIndex);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class HSSimpleSliverAppBar extends StatelessWidget {
  const HSSimpleSliverAppBar(
      {super.key, this.height, required this.child, this.leading});

  final double? height;
  final Widget child;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      expandedHeight: height,
      leading: leading,
      flexibleSpace: FlexibleSpaceBar(
        background: child,
      ),
    );
  }
}

class _SaveActionButton extends StatelessWidget {
  const _SaveActionButton(
      {this.accentColor, required this.status, required this.singleBoardCubit});

  final HSSingleBoardStatus status;
  final HSSingleBoardCubit singleBoardCubit;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    late final VoidCallback? onPressed;
    late final Widget icon;
    late final bool isEditor;
    isEditor = singleBoardCubit.state.isEditor;
    if (isEditor) {
      onPressed = () => navi.pushPage(
          page: CreateBoardProvider(prototype: singleBoardCubit.state.board));
      icon = Icon(FontAwesomeIcons.pen, color: accentColor);
    } else {
      switch (status) {
        case HSSingleBoardStatus.updating || HSSingleBoardStatus.loading:
          onPressed = null;
          icon = HSLoadingIndicator(size: 24, color: accentColor);
        case HSSingleBoardStatus.idle:
          onPressed = singleBoardCubit.saveUnsave;
          icon = singleBoardCubit.state.isBoardSaved
              ? Icon(FontAwesomeIcons.solidBookmark, color: appTheme.mainColor)
              : const Icon(FontAwesomeIcons.bookmark);
        case HSSingleBoardStatus.error:
          onPressed = null;
          icon = Icon(FontAwesomeIcons.bookmark, color: accentColor);
      }
    }
    return IconButton(
      onPressed: onPressed,
      icon: icon,
    );
  }
}
