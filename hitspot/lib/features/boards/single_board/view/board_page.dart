import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/boards/single_board/bloc/hs_board_bloc.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_loading_indicator.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/hs_spots_grid.dart';
import 'package:hitspot/widgets/hs_user_avatar.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';

class BoardPage extends StatelessWidget {
  const BoardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HSBoardBloc, HSBoardState>(
      builder: (context, state) {
        if (state is HSBoardErrorState) {
          return HSScaffold(
            appBar: HSAppBar(
              enableDefaultBackButton: true,
            ),
            body: Center(
              child: Text(
                state.error,
                style: textTheme.displayMedium!.colorify(Colors.red),
              ),
            ),
          );
        } else if (state is HSBoardReadyState) {
          final HSBoard board = state.board;
          final HSUser author = state.author;
          return HSScaffold(
            appBar: HSAppBar(
              enableDefaultBackButton: true,
              titleText: board.title,
            ),
            body: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 120,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            HSUserAvatar(
                              radius: 40.0,
                              imgUrl: author.profilePicture,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("@${author.username}",
                                    style: textTheme.headlineMedium),
                                Text(author.fullName!),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Divider(
                    thickness: .3,
                  ),
                ),
                const Gap(8.0).sliver,
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "About",
                        style: textTheme.headlineMedium,
                      ),
                      Text(
                        board.description!,
                      ),
                    ],
                  ),
                ),
                const Gap(16.0).sliver,
                const SliverToBoxAdapter(
                  child: Divider(
                    thickness: .3,
                  ),
                ),
                const Gap(8.0).sliver,
                HSSpotsGrid
                    .loading(), // TODO: Change when wojtek is done with adding spots
              ],
            ),
          );
        }
        return HSScaffold(
          appBar: HSAppBar(
            enableDefaultBackButton: true,
          ),
          body: const HSLoadingIndicator(),
        );
      },
    );
  }
}

extension SliverGap on Gap {
  SliverToBoxAdapter get sliver {
    return SliverToBoxAdapter(
      child: this,
    );
  }
}
