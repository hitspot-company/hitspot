import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/extensions/hs_sliver_extensions.dart';
import 'package:hitspot/features/boards/single/cubit/hs_single_board_cubit.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_image.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/hs_user_avatar.dart';
import 'package:hitspot/widgets/shimmers/hs_shimmer_box.dart';
import 'package:hitspot/widgets/shimmers/hs_shimmer_builders.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';

class SingleBoardPage extends StatelessWidget {
  const SingleBoardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final singleBoardCubit = BlocProvider.of<HSSingleBoardCubit>(context);
    return BlocSelector<HSSingleBoardCubit, HSSingleBoardState,
        HSSingleBoardStatus>(
      selector: (state) => state.status,
      builder: (context, status) {
        final bool isLoading = status == HSSingleBoardStatus.loading;
        final HSUser? author = singleBoardCubit.state.author;
        final HSBoard? board = singleBoardCubit.state.board;
        return HSScaffold(
          appBar: HSAppBar(
            enableDefaultBackButton: true,
            titleText: singleBoardCubit.state.board?.title ?? "",
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
              const HSShimmerGridBuilder(
                isSliver: true,
                crossAxisCount: 2,
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
