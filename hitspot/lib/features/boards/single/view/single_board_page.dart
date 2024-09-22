import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/extensions/hs_sliver_extensions.dart';
import 'package:hitspot/features/boards/single/cubit/hs_single_board_cubit.dart';
import 'package:hitspot/features/boards/single/map/view/single_board_map_provider.dart';
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
import 'package:flutter_animate/flutter_animate.dart';

class SingleBoardPage extends StatelessWidget {
  SingleBoardPage({super.key});

  final ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    final singleBoardCubit = BlocProvider.of<HSSingleBoardCubit>(context);
    return BlocBuilder<HSSingleBoardCubit, HSSingleBoardState>(
      buildWhen: (previous, current) =>
          previous.status != current.status || previous.spots != current.spots,
      builder: (context, state) {
        final bool isLoading = state.status == HSSingleBoardStatus.loading;
        final HSBoard? board = state.board;
        final HSUser? author = state.author;
        if (state.status == HSSingleBoardStatus.error) {
          return HSScaffold(
            appBar: HSAppBar(
              enableDefaultBackButton: true,
            ),
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
                    style: Theme.of(context).textTheme.headlineSmall,
                  ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
                  const Gap(16),
                  HSButton(
                    onPressed: singleBoardCubit.refresh,
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
        return RefreshIndicator(
          onRefresh: singleBoardCubit.refresh,
          child: HSScaffold(
            onTap: singleBoardCubit.exitEditMode,
            appBar: HSAppBar(
                enableDefaultBackButton: true,
                right: IconButton(
                  onPressed:
                      !isLoading ? singleBoardCubit.showBottomSheet : null,
                  icon: const Icon(FontAwesomeIcons.ellipsisVertical),
                )
                    .animate()
                    .fadeIn(duration: 300.ms, curve: Curves.easeInOut)
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1, 1),
                    )),
            body: CustomScrollView(
              controller: _scrollController,
              slivers: [
                if (board?.image != null)
                  HSSimpleSliverAppBar(
                      height: 120,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          HSImage(
                            onTap: singleBoardCubit.state.board?.image != null
                                ? () => app.gallery.showImageGallery(images: [
                                      singleBoardCubit.state.board!.image!
                                    ])
                                : null,
                            borderRadius: BorderRadius.circular(14.0),
                            imageUrl: singleBoardCubit.state.board?.image,
                            color: board?.color,
                          ),
                          Positioned(
                            bottom: 6,
                            left: 12,
                            child: GestureDetector(
                                onTap: () =>
                                    _showCollaboratorsMenu(singleBoardCubit),
                                child: _buildCollaboratorIcons(
                                    board?.collaborators)),
                          ),
                        ],
                      )),
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
                if (isLoading)
                  const HSShimmerBox(width: 60, height: 60.0)
                      .animate()
                      .fadeIn(duration: 300.ms, curve: Curves.easeInOut)
                      .toSliver
                else
                  HSSimpleSliverAppBar(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            HSUserAvatar(
                              radius: 24,
                              imageUrl: state.author?.avatarUrl,
                            ),
                            const Gap(16.0),
                            AutoSizeText(
                              author?.username ?? "",
                              style: Theme.of(context).textTheme.headlineMedium,
                              maxLines: 1,
                            ),
                            const Spacer(),
                            _SaveActionButton(
                              status: state.status,
                              singleBoardCubit: singleBoardCubit,
                            )
                                .animate()
                                .fadeIn(duration: 300.ms, delay: 400.ms)
                                .slideY(begin: 0.2, end: 0),
                            IconButton(
                              onPressed: () => navi.pushPage(
                                page: SingleBoardMapProvider(
                                    boardID: board!.id!, board: board),
                              ),
                              icon: const Icon(
                                FontAwesomeIcons.map,
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
                const Gap(16.0).toSliver,
                const SliverToBoxAdapter(
                  child: AnimatedEditableListView(),
                ),
                const Gap(32.0).toSliver,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCollaboratorIcons(List<HSUser>? collaborators) {
    if (collaborators == null || collaborators.isEmpty) {
      return const SizedBox.shrink();
    }

    // Limit the number of collaborators to show to 3
    late List<HSUser> collaboratorsToShow = collaborators;
    if (collaborators.length > 3) {
      collaboratorsToShow = collaborators.sublist(0, 3);
    }

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            collaboratorsToShow.length,
            (index) => Padding(
              padding: const EdgeInsets.only(right: 18.0),
              child: Align(
                widthFactor: 0.7,
                child: HSUserAvatar(
                    radius: 20.0,
                    imageUrl: collaboratorsToShow[index].avatarUrl),
              ),
            ),
          )),
    );
  }

  void _showCollaboratorsMenu(HSSingleBoardCubit singleBoardCubit) {
    final state = singleBoardCubit.state;
    if (state.board?.collaborators == null ||
        state.board?.collaborators?.isEmpty == true) {
      return;
    }

    showDialog(
      context: app.context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Collaborators'),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
          content: SingleChildScrollView(
            child: ListBody(
              children: state.board?.collaborators
                      ?.map((collaborator) => ListTile(
                            onTap: () => navi.toUser(userID: collaborator.uid!),
                            leading: HSUserAvatar(
                                radius: 20.0, imageUrl: collaborator.avatarUrl),
                            title: Text(collaborator.name ?? ""),
                            trailing: state.isOwner
                                ? IconButton(
                                    icon:
                                        const Icon(Icons.remove_circle_outline),
                                    onPressed: () {
                                      singleBoardCubit.removeCollaborator(
                                          state.board?.id, collaborator.uid);
                                      navi.pop();
                                    },
                                  )
                                : const SizedBox.shrink(),
                          ))
                      .toList() ??
                  [],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                navi.pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class AnimatedEditableListView extends StatelessWidget {
  const AnimatedEditableListView({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HSSingleBoardCubit>();
    return BlocBuilder<HSSingleBoardCubit, HSSingleBoardState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.spots != current.spots ||
          previous.board != current.board,
      builder: (context, state) {
        final isEditMode = state.status == HSSingleBoardStatus.editing;
        return GestureDetector(
          onLongPress: cubit.toggleEditMode,
          child: ReorderableListView.builder(
              buildDefaultDragHandles: isEditMode,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.spots.length,
              itemBuilder: (context, index) {
                return Padding(
                  key: ValueKey(state.spots[index].sid!),
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Stack(
                    children: [
                      HSSpotTile(
                        onLongPress: (p0) =>
                            isEditMode ? null : cubit.toggleEditMode,
                        index: index,
                        spot: state.spots[index],
                        extent: 160.0,
                      ),
                      if (isEditMode)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () => cubit.removeSpot(index),
                                icon: const Icon(FontAwesomeIcons.xmark),
                              ),
                              const SizedBox(width: 8.0),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.drag_handle,
                                ),
                              ),
                            ],
                          ),
                        ).animate().fade(duration: 300.ms),
                    ],
                  )
                      .animate(
                        target: isEditMode ? 1 : 0,
                        autoPlay: isEditMode,
                        onComplete: (controller) {
                          if (isEditMode) {
                            controller.repeat();
                          }
                        },
                      )
                      .shake(
                          hz: 2,
                          delay: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          rotation: .005),
                );
              },
              onReorder: cubit.reorderSpots),
        );
      },
    );
  }
}

class HSSimpleSliverAppBar extends StatelessWidget {
  const HSSimpleSliverAppBar(
      {super.key,
      this.height,
      required this.child,
      this.leading,
      this.pinned = false});

  final double? height;
  final Widget child;
  final Widget? leading;
  final bool pinned;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: pinned,
      forceMaterialTransparency: true,
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
      {required this.status, required this.singleBoardCubit, this.accentColor});

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
      return const SizedBox();
    } else {
      switch (status) {
        case HSSingleBoardStatus.updating ||
              HSSingleBoardStatus.loading ||
              HSSingleBoardStatus.editing:
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
