import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/app/hs_app.dart';
import 'package:hitspot/authentication/bloc/hs_authentication_bloc.dart';
import 'package:hitspot/utils/assets/hs_assets.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/hs_searchbar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static Page<void> page() => const MaterialPage<void>(child: HomePage());

  @override
  Widget build(BuildContext context) {
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
                  onPressed: () => context.read<HSAuthenticationBloc>().add(
                      const HSAppLogoutRequested()) // HSDebugLogger.logInfo("Notification"),
                  ),
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
                    style: HSApp.instance.textTheme.headlineSmall,
                  ),
                  TextSpan(
                    text: " ,\nWhere would you like to go?",
                    style: HSApp.instance.textTheme.headlineSmall!
                        .colorify(Colors.grey),
                  ),
                ],
              ),
              style:
                  HSApp.instance.textTheme.headlineSmall!.colorify(Colors.grey),
            ),
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
        ],
      ),
    );
  }
}
