import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/utils/navigation/hs_navigation.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/hs_spots_grid.dart';
import 'package:hitspot/widgets/hs_user_avatar.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const HomePage());
  }

  static Page<void> page() => const MaterialPage<void>(child: HomePage());

  @override
  Widget build(BuildContext context) {
    return HSScaffold(
      defaultBottombarEnabled: true,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            surfaceTintColor: Colors.transparent,
            title: Align(
              alignment: Alignment.centerLeft,
              child: Image.asset(
                app.assets.textLogo,
                height: 30,
                alignment: Alignment.centerLeft,
              ),
            ),
            actions: <Widget>[
              IconButton(
                icon:
                    HSUserAvatar(radius: 30.0, imageUrl: currentUser.avatarUrl),
                onPressed: () => navi.toUser(
                  userID: currentUser.uid!,
                ),
              ),
            ],
            floating: true,
            pinned: true,
          ),
          SliverAppBar(
            automaticallyImplyLeading: false,
            surfaceTintColor: Colors.transparent,
            centerTitle: false,
            title: Text.rich(
                TextSpan(
                  text: "Hello ",
                  children: [
                    TextSpan(
                        text: currentUser.username,
                        style: textTheme.headlineMedium),
                    TextSpan(
                        text: " ,\nWhere would you like to go?",
                        style: textTheme.headlineLarge!.hintify),
                  ],
                ),
                style: textTheme.headlineMedium!.hintify),
            floating: true,
            pinned: true,
          ),
          const SliverToBoxAdapter(
            child: Gap(16.0),
          ),
          // const SliverAppBar(
          //   automaticallyImplyLeading: false,
          //   surfaceTintColor: Colors.transparent,
          //   stretch: true,
          //   title: HSSearchBar(
          //     height: 60.0,
          //   ),
          //   centerTitle: true,
          //   pinned: true,
          //   toolbarHeight: 60,
          // ),
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 32.0,
            ),
          ),
          HSSpotsGrid.loading(isSliver: true)
        ],
      ),
    );
  }
}
