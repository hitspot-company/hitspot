import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/extensions/hs_sliver_extensions.dart';
import 'package:hitspot/features/boards/single/view/single_board_page.dart';
import 'package:hitspot/features/saved/cubit/hs_saved_cubit.dart';
import 'package:hitspot/widgets/board/hs_board_card.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_button.dart';
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
                        const Center(child: Text('No boards.')).toSliver,
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
          child: HSBoardCard(
                  board: board, height: 120.0, layout: HSBoardCardLayout.list)
              .animate()
              .fadeIn(duration: 300.ms, delay: (100 * index).ms)
              .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
        );
      },
    );
  }
}
