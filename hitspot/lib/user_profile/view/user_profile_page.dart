import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/app/hs_app.dart';
import 'package:hitspot/user_profile/bloc/hs_user_profile_bloc.dart';
import 'package:hitspot/user_profile/edit_profile/view/edit_profile_provider.dart';
import 'package:hitspot/utils/assets/hs_assets.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';
import 'package:hitspot/widgets/auth/hs_auth_button.dart';
import 'package:hitspot/widgets/auth/hs_auth_social_buttons.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_button.dart';
import 'package:hitspot/widgets/hs_loading_indicator.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ScrollController();
    final app = HSApp.instance;
    return BlocBuilder<HSUserProfileBloc, HSUserProfileState>(
      buildWhen: (previous, current) => previous.props != current.props,
      builder: (context, state) {
        switch (state) {
          case HSUserProfileInitialLoading():
            return Material(
              color: app.currentTheme.scaffoldBackgroundColor,
              child: const Center(
                child: HSLoadingIndicator(),
              ),
            );
          case HSUserProfileReady():
            final user =
                state.user.copyWith(spots: List.generate(16, (index) => null));
            return HSScaffold(
              appBar: HSAppBar(
                title: "@${state.user.username}",
                titleBold: true,
                enableDefaultBackButton: true,
              ),
              body: CustomScrollView(
                controller: controller,
                slivers: [
                  _UserDataAppBar(user: user),
                  _StatsAppBar(user: user),
                  const SliverToBoxAdapter(
                    child: Gap(16.0),
                  ),
                  SliverMasonryGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8.0,
                    crossAxisSpacing: 8.0,
                    childCount: user.spots?.length ?? 0,
                    itemBuilder: (context, index) {
                      return _SpotTile(
                        index: index,
                        extent: (index % 3 + 2) * 100,
                      );
                    },
                  ),
                ],
              ),
            );
          default:
            return HSScaffold(
              body: Container(),
            );
        }
      },
    );
  }

  Offset _calculateTiltOffset() {
    final random = Random();
    const double factor = 2.5;
    final double rx =
        random.nextDouble() * factor * (random.nextInt(2) % 2 == 0 ? 1 : -1);
    final double ry =
        random.nextDouble() * factor * (random.nextInt(2) % 2 == 0 ? 1 : -1);
    return Offset(rx, ry);
  }
}

class _StatsAppBar extends StatelessWidget {
  const _StatsAppBar({
    required this.user,
  });

  final HSUser user;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      surfaceTintColor: Colors.transparent,
      expandedHeight: 150.0,
      floating: true,
      snap: false,
      pinned: false,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
          background: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatsChip(
                label: "Followers",
                value: user.followers?.length,
              ),
              _StatsChip(
                label: "Following",
                value: user.following?.length,
              ),
              _StatsChip(
                label: "Spots",
                value: user.spots?.length,
              ),
            ],
          ),
          const SizedBox(
            height: 24.0,
          ),
          HSSocialLoginButtons.custom(
            labelText: "EDIT PROFILE",
            onPressed: () => HSApp.instance.navigation.push(
              EditProfileProvider.route(),
            ),
          ),
        ],
      )),
    );
  }
}

class _UserDataAppBar extends StatelessWidget {
  const _UserDataAppBar({
    required this.user,
  });

  final HSUser user;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      surfaceTintColor: Colors.transparent,
      expandedHeight: 140.0,
      floating: true,
      snap: false,
      pinned: false,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Row(
          children: [
            Expanded(
              child: CircleAvatar(
                radius: 60,
                child: SizedBox(
                  width: 60,
                  child: ClipOval(
                    child: Image.asset(
                      HSAssets.instance.logo,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("@${user.username!}"),
                  Text(
                    user.fullName!,
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user.biogram ?? "Biogram",
                  ),
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
    required this.label,
    required this.value,
  });

  final String label;
  final int? value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            children: [
              Text(label),
              Text(
                '${value ?? 0}',
                style: const TextStyle().boldify(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpotTile extends StatelessWidget {
  const _SpotTile({
    Key? key,
    required this.index,
    this.extent,
    this.backgroundColor,
    this.bottomSpace,
  }) : super(key: key);

  final int index;
  final double? extent;
  final double? bottomSpace;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final child = ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: Container(
        height: extent,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: Colors.grey,
        ),
        child: Image.network(
          _imgUrl(index),
          fit: BoxFit.cover,
          colorBlendMode: BlendMode.difference,
          color: Colors.black,
        ),
      ),
    ).animate().fadeIn();

    if (bottomSpace == null) {
      return child;
    }

    return Column(
      children: [
        Expanded(child: child),
        Container(
          height: bottomSpace,
          color: Colors.green,
        )
      ],
    );
  }

  String _imgUrl(int index) {
    return "https://picsum.photos/20$index";
  }
}
