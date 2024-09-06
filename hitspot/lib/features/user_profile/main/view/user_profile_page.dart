import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/extensions/hs_sliver_extensions.dart';
import 'package:hitspot/features/home/main/view/home_page.dart';
import 'package:hitspot/features/user_profile/main/cubit/hs_user_profile_cubit.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_icon_prompt.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/hs_shimmer.dart';
import 'package:hitspot/widgets/hs_user_avatar.dart';
import 'package:hitspot/widgets/shimmer_skeleton.dart';
import 'package:hitspot/widgets/shimmers/hs_shimmer_box.dart';
import 'package:hitspot/widgets/spot/hs_animated_spot_tile.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hitspot/widgets/hs_button.dart';
import 'package:zoom_pinch_overlay/zoom_pinch_overlay.dart';

part 'widgets/user_profile_widgets.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HSUserProfileCubit>();
    return BlocBuilder<HSUserProfileCubit, HSUserProfileState>(
      builder: (context, state) {
        final HSUser? user = state.user;
        final bool loading = state.status == HSUserProfileStatus.loading;
        final bool ownProfile = context.read<HSUserProfileCubit>().isOwnProfile;
        return HSScaffold(
          appBar: HSAppBar(
            enableDefaultBackButton: true,
            right: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (ownProfile)
                  IconButton(
                    onPressed: navi.toSettings,
                    icon: const Icon(FontAwesomeIcons.sliders),
                  ),
              ],
            ),
          ),
          body: RefreshIndicator(
            onRefresh: cubit.refresh,
            child: DefaultTabController(
              length: 2,
              child: CustomScrollView(
                slivers: [
                  _UserProfileInfo(
                    context: context,
                    loading: loading,
                    user: user,
                  ).toSliver,
                  const Gap(8.0).toSliver,
                  _UserProfileActionButton(isLoading: loading).toSliver,
                  const Gap(8.0).toSliver,
                  _UserDataBar(loading: loading, user: user).toSliver,
                  const Gap(16.0).toSliver,
                  _TabBarWidget().toSliver,
                  SliverFillRemaining(
                    child: TabBarView(
                      children: [
                        _TabContent(
                          context: context,
                          isLoading: loading,
                          elements: state.spots,
                          title: 'Spots',
                        ),
                        _TabContent(
                          context: context,
                          isLoading: loading,
                          elements: state.boards,
                          title: 'Boards',
                        ),
                      ],
                    ),
                  ),
                  const Gap(16.0).toSliver,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
