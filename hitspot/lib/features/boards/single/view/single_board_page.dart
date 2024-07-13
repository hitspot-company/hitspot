import 'package:auto_size_text/auto_size_text.dart';
import 'package:avatar_stack/avatar_stack.dart';
import 'package:avatar_stack/positions.dart';
import 'package:flutter/material.dart';
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
import 'package:hitspot/widgets/hs_user_avatar.dart';
import 'package:hitspot/widgets/shimmers/hs_shimmer_box.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';

import 'package:flutter_animate/flutter_animate.dart';

class SingleBoardPage extends StatelessWidget {
  const SingleBoardPage({super.key});

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
        if (state.status == HSSingleBoardStatus.error) {
          return HSScaffold(
            appBar: HSAppBar(enableDefaultBackButton: true),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48)
                      .animate()
                      .fadeIn(duration: 300.ms, curve: Curves.easeInOut)
                      .scale(
                          begin: const Offset(0.8, 0.8),
                          end: const Offset(1, 1)),
                  const Gap(16),
                  Text(
                    'Something went wrong.',
                    style: textTheme.headlineSmall,
                  ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
                  const Gap(16),
                  HSButton(
                    onPressed: () {},
                    child: const Text("Retry"),
                  )
                      .animate()
                      .fadeIn(duration: 300.ms, delay: 200.ms)
                      .slideY(begin: 0.2, end: 0),
                ],
              ),
            ),
          );
        }
        return HSScaffold(
          appBar: HSAppBar(
            enableDefaultBackButton: true,
            right: IconButton(
              onPressed: () => HSDebugLogger.logInfo("More"),
              icon: const Icon(FontAwesomeIcons.ellipsisVertical),
            ).animate().fadeIn(duration: 300.ms, curve: Curves.easeInOut).scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1, 1),
                ),
          ),
          floatingActionButton: HSButton.icon(
            label: Text("Create Trip",
                style: textTheme.headlineMedium!.colorify(appTheme.mainColor)),
            icon: const Icon(FontAwesomeIcons.mapPin),
            onPressed: () => HSDebugLogger.logInfo("Creating trip!"),
          ).animate().fadeIn(duration: 300.ms, curve: Curves.easeInOut).scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1, 1),
              ),
          body: CustomScrollView(
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
              if (isLoading)
                const HSShimmerBox(width: 60, height: 60.0)
                    .animate()
                    .fadeIn(duration: 300.ms, curve: Curves.easeInOut)
                    .toSliver
              else
                SliverToBoxAdapter(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      board!.title!,
                      style: const TextStyle(
                        fontSize: 30.0,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                    )
                        .animate()
                        .fadeIn(duration: 300.ms, delay: 100.ms)
                        .slideY(begin: 0.2, end: 0),
                    Text(
                      board.description!,
                      style: const TextStyle(color: Colors.grey),
                    )
                        .animate()
                        .fadeIn(duration: 300.ms, delay: 200.ms)
                        .slideY(begin: 0.2, end: 0),
                  ],
                )),
              const SliverToBoxAdapter(child: Gap(16.0)),
              HSSimpleSliverAppBar(
                height: 100.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _AvatarStack(
                            height: 50.0,
                            collaborators:
                                singleBoardCubit.state.board?.collaborators ??
                                    []),
                        const Spacer(),
                        if (isLoading)
                          const Expanded(
                            child: HSShimmerBox(width: 60, height: 60.0),
                          )
                        else
                          _SaveActionButton(
                            status: state.status,
                            singleBoardCubit: singleBoardCubit,
                          )
                              .animate()
                              .fadeIn(duration: 300.ms, delay: 400.ms)
                              .slideY(begin: 0.2, end: 0),
                        IconButton(
                          onPressed: () => HSDebugLogger.logInfo("Share"),
                          icon: const Icon(
                            FontAwesomeIcons.arrowUpRightFromSquare,
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 300.ms, delay: 500.ms)
                            .slideY(begin: 0.2, end: 0),
                      ],
                    ),
                  ],
                ),
              ),
              const Gap(24.0).toSliver,
              SliverMasonryGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
                childCount: spots.length,
                itemBuilder: (context, index) {
                  return HSSpotTile(
                    onLongPress: singleBoardCubit.onLongPress,
                    index: index,
                    spot: spots[index],
                    extent: (index % 3 + 2) * 70.0 + 70.0,
                  )
                      .animate()
                      .fadeIn(duration: 300.ms, delay: (400 + index * 100).ms)
                      .scale(
                        begin: const Offset(0.95, 0.95),
                        end: const Offset(1, 1),
                      );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AvatarStack extends StatelessWidget {
  const _AvatarStack(
      {required this.collaborators, this.height = 80.0, this.width});
  final List<HSUser>? collaborators;
  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final settings = RestrictedPositions(
      maxCoverage: .7,
      minCoverage: .3,
      align: StackAlign.left,
    );
    if (collaborators == null) {
      return const SizedBox();
    }
    return SizedBox(
      height: height,
      width: width ?? screenWidth / 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: WidgetStack(
              positions: settings,
              stackedWidgets: [
                for (var n = 0; n < collaborators!.length; n++)
                  HSUserAvatar(
                      radius: 30.0, imageUrl: collaborators![n].avatarUrl),
              ],
              buildInfoWidget: (surplus) {
                return Center(
                  child: Text(
                    '+$surplus',
                    style: textTheme.headlineMedium,
                  ),
                );
              },
            ),
          ),
          // AutoSizeText(usernames, textAlign: TextAlign.left, maxLines: 1),
        ],
      ),
    );
  }

  // String get usernames {
  //   if (collaborators == null || collaborators!.isEmpty) {
  //     return "";
  //   }
  //   final count = collaborators!.length > 5 ? 4 : collaborators!.length - 1;
  //   final names = collaborators!.sublist(0, count).map((e) => e.username);
  //   final res = names.join(", ");
  //   if (count > 0) res += " and ${collaborators!.length - count} others";
  // }
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
          onPressed = singleBoardCubit.saveUnsave;
          icon = const Icon(FontAwesomeIcons.bookmark);
      }
    }
    return IconButton(
      onPressed: onPressed,
      icon: icon,
    );
  }
}
