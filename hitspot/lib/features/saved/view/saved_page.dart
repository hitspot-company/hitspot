import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/saved/bloc/hs_saved_bloc.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_boards_list.dart';
import 'package:hitspot/widgets/hs_button.dart';
import 'package:hitspot/widgets/hs_loading_indicator.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';

class SavedPage extends StatelessWidget {
  const SavedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final savedBloc = context.read<HSSavedBloc>();
    return HSScaffold(
      appBar: HSAppBar(enableDefaultBackButton: true),
      body: BlocBuilder<HSSavedBloc, HSSavedState>(
        builder: (context, state) {
          if (state is HSSavedReadyState) {
            final List<HSBoard> userBoards = state.userBoards;
            final List<HSBoard> savedBoards = state.savedBoards;

            return ListView(
              shrinkWrap: true,
              children: [
                Text("Your Boards", style: textTheme.headlineMedium),
                const Gap(8.0),
                if (userBoards.isNotEmpty)
                  HSBoardsList(boards: userBoards, user: currentUser),
                if (userBoards.isEmpty)
                  Column(
                    children: [
                      Text("You don't have any boards yet.",
                          style: textTheme.titleMedium),
                      const Gap(8.0),
                      HSButton(
                        child: const Text("Create Board"),
                        onPressed: () => navi.newPush("/add_board"),
                      ),
                    ],
                  ),
                const Gap(32.0),
                Text("Saved Boards", style: textTheme.headlineMedium),
                const Gap(16.0),
                if (savedBoards.isNotEmpty)
                  HSBoardsList(boards: savedBoards, user: currentUser),
                const Gap(16.0),
                if (savedBoards.isEmpty)
                  Column(
                    children: [
                      Text("You don't have any saved boards yet.",
                          style: textTheme.titleMedium),
                      const Gap(8.0),
                      HSButton(
                          child: const Text("Find Boards"),
                          onPressed: () => HSDebugLogger.logInfo("Find Board")),
                    ],
                  ),
              ],
            );
          }
          return const HSLoadingIndicator();
        },
      ),
    );
  }
}
