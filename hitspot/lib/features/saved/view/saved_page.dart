import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/saved/cubit/hs_saved_cubit.dart';
import 'package:hitspot/widgets/hs_icon_prompt.dart';
import 'package:hitspot/widgets/hs_image.dart';
import 'package:hitspot/widgets/shimmers/hs_shimmer_box.dart';
import 'package:hs_database_repository/src/boards/hs_board.dart';

class SavedPage extends StatelessWidget {
  const SavedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Saved'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Your Boards'),
              Tab(text: 'Saved Boards'),
              // Tab(text: 'Saved Spots'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _OwnBoardsBuilder(),
            _SavedBoardsBuilder(),
          ],
        ),
      ),
    );
  }
}

class _LoadingBuilder extends StatelessWidget {
  const _LoadingBuilder();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.separated(
        itemCount: 6,
        separatorBuilder: (BuildContext context, int index) {
          return const Gap(16.0);
        },
        itemBuilder: (BuildContext context, int index) {
          return HSShimmerBox(height: 80.0, width: screenWidth);
        },
      ),
    );
  }
}

class _SavedBoardsBuilder extends StatelessWidget {
  const _SavedBoardsBuilder();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HSSavedCubit, HSSavedState>(
      buildWhen: (previous, current) =>
          previous.savedBoards != current.savedBoards ||
          previous.status != current.status,
      builder: (context, state) {
        final isLoading = state.status == HSSavedStatus.loading;
        final isEmpty = state.savedBoards.isEmpty;
        if (isLoading) {
          return const _LoadingBuilder();
        }
        if (isEmpty) {
          return const HSIconPrompt(
              message: "No saved boards", iconData: FontAwesomeIcons.bookmark);
        }
        final boards = state.savedBoards;
        return _BoardsBuilder(boards: boards);
      },
    );
  }
}

class _OwnBoardsBuilder extends StatelessWidget {
  const _OwnBoardsBuilder();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HSSavedCubit, HSSavedState>(
      buildWhen: (previous, current) =>
          previous.ownBoards != current.ownBoards ||
          previous.status != current.status,
      builder: (context, state) {
        final isLoading = state.status == HSSavedStatus.loading;
        final isEmpty = state.ownBoards.isEmpty;
        if (isLoading) {
          return const _LoadingBuilder();
        }
        if (isEmpty) {
          return const HSIconPrompt(
              message: "You don't have any boards",
              iconData: FontAwesomeIcons.bookmark);
        }
        final boards = state.ownBoards;
        return _BoardsBuilder(boards: boards);
      },
    );
  }
}

class _BoardsBuilder extends StatelessWidget {
  const _BoardsBuilder({
    required this.boards,
  });

  final List<HSBoard> boards;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: boards.length,
      separatorBuilder: (BuildContext context, int index) {
        return const Gap(16.0);
      },
      itemBuilder: (BuildContext context, int index) {
        final board = boards[index];
        return ListTile(
          onTap: () => navi.toBoard(boardID: board.id!, title: board.title!),
          leading: AspectRatio(
              aspectRatio: 1.0,
              child: HSImage(
                imageUrl: boards[index].image,
                borderRadius: BorderRadius.circular(10.0),
              )),
          title: Text(board.title!),
          subtitle: Text(board.description!),
        );
      },
    );
  }
}
