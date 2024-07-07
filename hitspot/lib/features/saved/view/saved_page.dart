import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/extensions/hs_sliver_extensions.dart';
import 'package:hitspot/features/boards/single/view/single_board_page.dart';
import 'package:hitspot/features/saved/cubit/hs_saved_cubit.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_button.dart';
import 'package:hitspot/widgets/hs_image.dart';
import 'package:hitspot/widgets/hs_loading_indicator.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SavedPage extends StatelessWidget {
  const SavedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final savedCubit = BlocProvider.of<HSSavedCubit>(context);
    return HSScaffold(
      appBar: HSAppBar(
        enableDefaultBackButton: true,
        titleText: 'Saved',
        titleBold: true,
      ),
      body: BlocSelector<HSSavedCubit, HSSavedState, HSSavedStatus>(
        selector: (state) => state.status,
        builder: (context, state) {
          switch (state) {
            case HSSavedStatus.loading:
              return const HSLoadingIndicator()
                  .animate()
                  .fadeIn(duration: 300.ms, curve: Curves.easeInOut);
            case HSSavedStatus.error:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 48)
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
              );
            case HSSavedStatus.idle:
              return CustomScrollView(
                slivers: [
                  const Gap(16.0).toSliver,
                  HSSimpleSliverAppBar(
                    child: Text(
                      "Saved boards",
                      style: textTheme.headlineLarge,
                    )
                        .animate()
                        .fadeIn(duration: 300.ms, delay: 100.ms)
                        .slideY(begin: 0.2, end: 0),
                  ),
                  if (savedCubit.state.savedBoards.isEmpty)
                    SliverMainAxisGroup(
                      slivers: [
                        const Center(child: Text('No boards saved yet.'))
                            .animate()
                            .fadeIn(duration: 300.ms, delay: 200.ms)
                            .slideY(begin: 0.2, end: 0)
                            .toSliver,
                        const Gap(16.0).toSliver,
                        HSButton(
                                child: const Text("Find Boards"),
                                onPressed: () =>
                                    HSDebugLogger.logInfo("Find Boards"))
                            .animate()
                            .fadeIn(duration: 300.ms, delay: 300.ms)
                            .slideY(begin: 0.2, end: 0)
                            .toSliver,
                      ],
                    )
                  else
                    _BoardsBuilder(
                      savedCubit: savedCubit,
                      boards: savedCubit.state.savedBoards,
                    ),
                  const Gap(16.0).toSliver,
                  HSSimpleSliverAppBar(
                    child: Text(
                      "Your boards",
                      style: textTheme.headlineLarge,
                    )
                        .animate()
                        .fadeIn(duration: 300.ms, delay: 400.ms)
                        .slideY(begin: 0.2, end: 0),
                  ),
                  if (savedCubit.state.ownBoards.isEmpty)
                    SliverMainAxisGroup(
                      slivers: [
                        const Center(child: Text('No boards.'))
                            .animate()
                            .fadeIn(duration: 300.ms, delay: 500.ms)
                            .slideY(begin: 0.2, end: 0)
                            .toSliver,
                      ],
                    )
                  else
                    _BoardsBuilder(
                      savedCubit: savedCubit,
                      boards: savedCubit.state.ownBoards,
                    ),
                  const Gap(16.0).toSliver,
                  HSButton(
                    onPressed: navi.toCreateBoard,
                    child: const Text("Create Board"),
                  )
                      .animate()
                      .fadeIn(duration: 300.ms, delay: 600.ms)
                      .slideY(begin: 0.2, end: 0)
                      .toSliver,
                  const Gap(32.0).toSliver,
                ],
              );
          }
        },
      ),
    );
  }
}

class _BoardsBuilder extends StatelessWidget {
  const _BoardsBuilder({
    required this.savedCubit,
    required this.boards,
  });

  final HSSavedCubit savedCubit;
  final List<HSBoard> boards;

  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
      itemCount: boards.length,
      separatorBuilder: (BuildContext context, int index) => const Gap(16.0),
      itemBuilder: (BuildContext context, int index) {
        final HSBoard board = boards[index];
        return GestureDetector(
          onTap: () => navi.toBoard(boardID: board.id!, title: board.title),
          child: HSBoardTile(board: board, height: 120.0)
              .animate()
              .fadeIn(duration: 300.ms, delay: (100 * index).ms)
              .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
        );
      },
    );
  }
}

class HSBoardTile extends StatelessWidget {
  const HSBoardTile({
    Key? key,
    required this.board,
    required this.height,
  }) : super(key: key);

  final HSBoard board;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: screenWidth,
      height: 100.0,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          HSImage(
            imageUrl: board.image,
            borderRadius: BorderRadius.circular(12.0),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                stops: const [0.0, .5, 1.0],
                colors: [
                  Colors.black,
                  Colors.black.withOpacity(.8),
                  Colors.black.withOpacity(.4),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 8.0,
            left: 16.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  board.title!,
                  style: Theme.of(context).textTheme.headlineMedium,
                  maxLines: 2,
                ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
                Text(
                  board.description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
              ],
            ),
          )
        ],
      ),
      // child: Row(
      //   children: [
      //     Container(
      //       width: 80,
      //       height: height - 16,
      //       decoration: BoxDecoration(
      //         borderRadius: BorderRadius.circular(8.0),
      //         color: Colors.grey[300],
      //       ),
      //       child: board.image != null
      //           ?
      //           : const Icon(
      //               Icons.image,
      //               size: 40,
      //               color: Colors.grey,
      //             ),
      //     ),
      //     const Gap(16),
      //     Expanded(
      //       child: Column(
      //         crossAxisAlignment: CrossAxisAlignment.start,
      //         mainAxisAlignment: MainAxisAlignment.center,
      //         children: [
      //           Text(
      //             board.title!,
      //             style: Theme.of(context).textTheme.titleMedium,
      //             overflow: TextOverflow.ellipsis,
      //             maxLines: 2,
      //           ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
      //           const Gap(8),
      //           Text(
      //             board.description!,
      //             style: Theme.of(context).textTheme.bodyMedium,
      //             overflow: TextOverflow.ellipsis,
      //           ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
      //         ],
      //       ),
      //     ),
      //     const Icon(Icons.arrow_forward_ios, size: 16)
      //         .animate()
      //         .fadeIn(duration: 300.ms, delay: 300.ms),

      // ],
      // ),
    );
  }
}
