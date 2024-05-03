import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/add_spot/view/add_spot_page.dart';
import 'package:hitspot/app/hs_app.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/user_profile/main/view/user_profile_provider.dart';
import 'package:hitspot/utils/assets/hs_assets.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/hs_searchbar.dart';
import 'package:hitspot/widgets/hs_spots_grid.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const HomePage());
  }

  static Page<void> page() => const MaterialPage<void>(child: HomePage());

  @override
  Widget build(BuildContext context) {
    final app = HSApp.instance;
    final navi = app.navigation;
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
                HSAssets.instance.textLogo,
                height: 30,
                alignment: Alignment.centerLeft,
              ),
            ),
            actions: <Widget>[
              IconButton(
                icon: CircleAvatar(
                  foregroundImage: app.currentUser.profilePicture != null
                      ? NetworkImage(app.currentUser.profilePicture!)
                      : null,
                  child: app.currentUser.profilePicture == null
                      ? const Icon(FontAwesomeIcons.solidUser)
                      : null,
                ),
                onPressed: () => navi.navigatorKey.currentState?.push(
                  UserProfileProvider.route(currentUser.uid!),
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
                        text: HSApp.instance.username,
                        style: textTheme.headlineMedium),
                    TextSpan(
                        text: " ,\nWhere would you like to go?",
                        style: HSApp.instance.textTheme.headlineLarge!.hintify),
                  ],
                ),
                style: HSApp.instance.textTheme.headlineMedium!.hintify),
            floating: true,
            pinned: true,
          ),
          const SliverToBoxAdapter(
            child: Gap(16.0),
          ),
          const SliverAppBar(
            automaticallyImplyLeading: false,
            surfaceTintColor: Colors.transparent,
            stretch: true,
            title: HSSearchBar(
              height: 60.0,
            ),
            centerTitle: true,
            pinned: true,
            toolbarHeight: 60,
          ),
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 32.0,
            ),
          ),
          HSSpotsGrid.loading(isSliver: true)
        ],
      ),
      bottomAppBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  hsNavigation.push(AddSpotPage.route());
                },
              ),
            ],
          )),
    );
  }
}
