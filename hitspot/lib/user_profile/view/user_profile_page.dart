import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/app/hs_app.dart';
import 'package:hitspot/user_profile/bloc/hs_user_profile_bloc.dart';
import 'package:hitspot/utils/assets/hs_assets.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_loading_indicator.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = HSApp.instance;
    return BlocBuilder<HSUserProfileBloc, HSUserProfileState>(
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
                slivers: [
                  _UserDataAppBar(user: user),
                  _StatsAppBar(user: user),
                  const SliverToBoxAdapter(
                    child: Gap(16.0),
                  ),
                  SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      mainAxisSpacing: 16.0,
                      crossAxisSpacing: 16.0,
                      crossAxisCount: 3,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          color:
                              index.isEven ? Colors.teal : Colors.purpleAccent,
                        ),
                      ),
                      childCount: user.spots!.length,
                    ),
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
}

class _StatsAppBar extends StatelessWidget {
  const _StatsAppBar({
    super.key,
    required this.user,
  });

  final HSUser user;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      surfaceTintColor: Colors.transparent,
      expandedHeight: 70.0,
      floating: true,
      snap: false,
      pinned: false,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Row(
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
      ),
    );
  }
}

class _UserDataAppBar extends StatelessWidget {
  const _UserDataAppBar({
    super.key,
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
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: CupertinoButton(
                        color: HSApp.instance.theme.mainColor,
                        child: const Text("Follow"),
                        onPressed: () => HSDebugLogger.logInfo("follow")),
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
