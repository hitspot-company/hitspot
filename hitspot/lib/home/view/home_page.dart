import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/add_spot/view/add_spot_page.dart';
import 'package:hitspot/app/hs_app.dart';
import 'package:hitspot/theme/bloc/hs_theme_bloc.dart';
import 'package:hitspot/utils/assets/hs_assets.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/hs_searchbar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static Page<void> page() => const MaterialPage<void>(child: HomePage());
  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const HomePage());
  }

  @override
  Widget build(BuildContext context) {
    final hsApp = HSApp.instance;
    final hsNavigation = hsApp.navigation;

    return HSScaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            surfaceTintColor: Colors.transparent,
            title: Image.asset(
              HSAssets.instance.textLogo,
              height: 30,
            ),
            actions: <Widget>[
              IconButton(
                icon: const Icon(FontAwesomeIcons.bell),
                onPressed: HSApp.instance.logout,
              ), // HSDebugLogger.logInfo("Notification"),
            ],
            floating: true,
            pinned: true,
          ),
          SliverAppBar(
            surfaceTintColor: Colors.transparent,
            centerTitle: false,
            title: Text.rich(
                TextSpan(
                  text: "Hello ",
                  children: [
                    TextSpan(
                        text: HSApp.instance.username,
                        style: HSApp.instance.textTheme.headlineSmall),
                    TextSpan(
                        text: " ,\nWhere would you like to go?",
                        style:
                            HSApp.instance.textTheme.headlineSmall!.hintify()),
                  ],
                ),
                style: HSApp.instance.textTheme.headlineSmall!.hintify()),
            floating: true,
            pinned: true,
          ),
          const SliverToBoxAdapter(
            child: Gap(16.0),
          ),
          const SliverAppBar(
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
          SliverToBoxAdapter(
            child: CupertinoButton(
              onPressed: HSApp.instance.changeTheme,
              color: HSApp.instance.theme.mainColor,
              child: const Text("Change theme!"),
            ),
          )
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
