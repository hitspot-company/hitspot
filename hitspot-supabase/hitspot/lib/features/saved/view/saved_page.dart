import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
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
              return ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    "Saved boards",
                    style: textTheme.headlineLarge,
                  ),
                  const Gap(16.0),
                  if (savedCubit.state.savedBoards.isEmpty)
                    Column(
                      children: [
                        const Center(child: Text('No boards saved yet.')),
                        const Gap(16.0),
                        HSButton(
                            child: const Text("Find Boards"),
                            onPressed: () =>
                                HSDebugLogger.logInfo("Find Boards")),
                      ],
                    ),
                  _BoardsBuilder(
                    savedCubit: savedCubit,
                    boards: savedCubit.state.savedBoards,
                  ),
                  const Gap(16.0),
                  Text(
                    "Your boards",
                    style: textTheme.headlineLarge,
                  ),
                  const Gap(16.0),
                  if (savedCubit.state.ownBoards.isEmpty)
                    Column(
                      children: [
                        const Center(child: Text('No boards.')),
                        const Gap(16.0),
                        HSButton(
                            child: const Text("Create Board"),
                            onPressed: () => HSDebugLogger.logInfo("Create")),
                      ],
                    ),
                  _BoardsBuilder(
                    savedCubit: savedCubit,
                    boards: savedCubit.state.ownBoards,
                  ),
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
    return ListView.separated(
      shrinkWrap: true,
      itemCount: boards.length,
      separatorBuilder: (context, index) => const Gap(16.0),
      itemBuilder: (BuildContext context, int index) {
        final HSBoard board = boards[index];
        return GestureDetector(
          onTap: () => navi.toBoard(boardID: board.id!, title: board.title),
          child: HSImage(
            opacity: .6,
            borderRadius: BorderRadius.circular(14.0),
            height: 70,
            width: screenWidth,
            imageUrl: board.image,
            color: board.color ?? appTheme.textfieldFillColor,
            child: Text(board.title!, style: textTheme.headlineSmall),
          ),
        );
      },
    );
  }
}
