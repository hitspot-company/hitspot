import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/extensions/hs_sliver_extensions.dart';
import 'package:hitspot/features/boards/single/view/single_board_page.dart';
import 'package:hitspot/features/home/main/view/home_page.dart';
import 'package:hitspot/features/saved/cubit/hs_saved_cubit.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_button%20copy.dart';
import 'package:hitspot/widgets/hs_image.dart';
import 'package:hitspot/widgets/hs_loading_indicator.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';

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
              return const HSLoadingIndicator();
            case HSSavedStatus.error:
              return const Center(child: Text('Error'));
            case HSSavedStatus.idle:
              return CustomScrollView(
                slivers: [
                  const Gap(16.0).toSliver,
                  HSSimpleSliverAppBar(
                    child: Text(
                      "Saved boards",
                      style: textTheme.headlineLarge,
                    ),
                  ),
                  if (savedCubit.state.savedBoards.isEmpty)
                    SliverMainAxisGroup(
                      slivers: [
                        const Center(child: Text('No boards saved yet.'))
                            .toSliver,
                        const Gap(16.0).toSliver,
                        HSButton(
                            child: const Text("Find Boards"),
                            onPressed: () =>
                                HSDebugLogger.logInfo("Find Boards")).toSliver,
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
                    ),
                  ),
                  if (savedCubit.state.ownBoards.isEmpty)
                    SliverMainAxisGroup(
                      slivers: [
                        const Center(child: Text('No boards.')).toSliver,
                        const Gap(16.0).toSliver,
                        HSButton(
                            child: const Text("Create Board"),
                            onPressed: () =>
                                HSDebugLogger.logInfo("Create")).toSliver,
                      ],
                    )
                  else
                    _BoardsBuilder(
                      savedCubit: savedCubit,
                      boards: savedCubit.state.ownBoards,
                    ),
                  const Gap(32.0).toSliver
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
          child: HSBoardTile(board: board, height: 120.0),
        );
      },
    );
  }
}
