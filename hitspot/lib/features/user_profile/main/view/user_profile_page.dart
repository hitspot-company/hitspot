import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/user_profile/main/bloc/hs_user_profile_bloc.dart';
import 'package:hitspot/features/user_profile/main/view/widgets/ready/hs_user_profile_headline.dart';
import 'package:hitspot/features/user_profile/main/view/widgets/ready/hs_user_profile_stats_app_bar.dart';
import 'package:hitspot/features/user_profile/main/view/widgets/ready/hs_user_profile_stats_chip_ready.dart';
import 'package:hitspot/features/user_profile/main/view/widgets/ready/hs_user_profile_user_data_app_bar_ready.dart';
import 'package:hitspot/features/user_profile/main/view/widgets/skeletons/hs_user_profile_stats_chip_skeleton.dart';
import 'package:hitspot/features/user_profile/main/view/widgets/skeletons/hs_user_profile_app_bar_skeleton.dart';
import 'package:hitspot/features/user_profile/settings/view/settings_provider.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_boards_list.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/hs_spots_grid.dart';
import 'package:hitspot/widgets/hs_user_avatar.dart';
import 'package:hitspot/widgets/hs_user_monitor.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ScrollController();
    return BlocBuilder<HSUserProfileBloc, HSUserProfileState>(
      buildWhen: (previous, current) => previous.props != current.props,
      builder: (context, state) {
        final userProfileBloc = context.read<HSUserProfileBloc>();
        if (state is HSUserProfileInitialLoading) {
          return _LoadingPage(controller: controller);
        } else if (state is HSUserProfileReady ||
            state is HSUserProfileUpdate) {
          late final HSUser user;
          late final List<HSBoard>? boards;
          if (state is HSUserProfileReady) {
            user = state.user!;
            boards = state.boards;
          } else if (state is HSUserProfileUpdate) {
            user = state.user!;
            boards = state.boards;
          }
          return _ReadyPage(
              controller: controller,
              user: user,
              boards: boards,
              userProfileBloc: userProfileBloc);
        }
        return HSScaffold(
          appBar: HSAppBar(
            enableDefaultBackButton: true,
            titleText: "",
          ),
          body: const Center(
            child: Text(
                "An error occured. Please try again later."), // TODO: redirect to error page
          ),
        );
      },
    );
  }
}

class _ReadyPage extends StatelessWidget {
  const _ReadyPage({
    required this.controller,
    required this.userProfileBloc,
    required this.user,
    this.boards,
  });

  final ScrollController controller;
  final HSUserProfileBloc userProfileBloc;
  final HSUser user;
  final List<HSBoard>? boards;

  @override
  Widget build(BuildContext context) {
    return HSScaffold(
      appBar: HSAppBar(
        titleText: "",
        titleBold: true,
        enableDefaultBackButton: true,
        right: userProfileBloc.isOwnProfile
            ? IconButton(
                onPressed: () => navi.push(SettingsProvider.route()),
                icon: const Icon(FontAwesomeIcons.bars))
            : const SizedBox(),
      ),
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              _UserDataAppBar.ready(user),
              const SliverToBoxAdapter(
                child: Gap(16.0),
              ),
              if (user.biogram != null)
                SliverMainAxisGroup(
                  slivers: [
                    const HSUserProfileHeadline(title: "BIO"),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          user.biogram!,
                          style: textTheme.titleSmall,
                        ),
                      ),
                    )
                  ],
                ),
              const SliverToBoxAdapter(
                child: Gap(16.0),
              ),
              HSUserProfileStatsAppBar.ready(
                  user: user, userProfileBloc: userProfileBloc),
              const SliverToBoxAdapter(
                child: TabBar(
                  tabs: [
                    Tab(
                      text: "Spots",
                    ),
                    Tab(
                      text: "Boards",
                    ),
                  ],
                ),
              ),
              const SliverToBoxAdapter(
                child: Gap(16.0),
              ),
            ];
          },
          body: TabBarView(
            children: [
              HSSpotsGrid.ready(spots: user.spots),
              HSBoardsList(boards: boards, user: user),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingPage extends StatelessWidget {
  const _LoadingPage({required this.controller});

  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    return HSScaffold(
      appBar: HSAppBar(
        titleText: "",
        titleBold: true,
        enableDefaultBackButton: true,
      ),
      body: CustomScrollView(
        controller: controller,
        slivers: [
          _UserDataAppBar.loading(),
          const SliverToBoxAdapter(
            child: Gap(16.0),
          ),
          const SliverToBoxAdapter(
            child: Divider(
              thickness: .1,
            ),
          ),
          const SliverToBoxAdapter(
            child: Gap(16.0),
          ),
          HSUserProfileStatsAppBar.loading(),
          const HSUserProfileHeadline(title: "SPOTS"),
          const SliverToBoxAdapter(
            child: Gap(16.0),
          ),
          HSSpotsGrid.loading(isSliver: true),
        ],
      ),
    );
  }
}

class _UserDataAppBar extends StatelessWidget {
  const _UserDataAppBar({
    this.user = const HSUser(),
    this.loading = false,
  });

  final HSUser? user;
  final bool loading;

  factory _UserDataAppBar.loading() {
    return const _UserDataAppBar(
      user: HSUser(),
      loading: true,
    );
  }

  factory _UserDataAppBar.ready(HSUser user) {
    return _UserDataAppBar(
      user: user,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!loading) user!;
    return SliverAppBar(
      surfaceTintColor: const Color.fromARGB(0, 97, 51, 51),
      expandedHeight: 140.0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Row(
          children: [
            Expanded(
              child: HSUserMonitor(
                child: HSUserAvatar(
                  loading: loading,
                  radius: 70.0,
                  iconSize: 50,
                  imgUrl: user?.profilePicture,
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  loading
                      ? const HSUserProfileUserDataAppBarSkeleton()
                      : HSUserProfileUserDataAppBarReady(user: user!),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsChip extends StatelessWidget {
  const _StatsChip({
    this.label,
    this.value,
    this.loading = false,
  });

  final String? label;
  final int? value;
  final bool loading;

  factory _StatsChip.loading() {
    return const _StatsChip(loading: true);
  }

  factory _StatsChip.ready({required String label, required int value}) {
    return _StatsChip(
      label: label,
      value: value,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: loading
          ? const HSUserProfileStatsChipSkeleton()
          : HSUserProfileStatsChipReady(label: label!, value: value),
    );
  }
}
