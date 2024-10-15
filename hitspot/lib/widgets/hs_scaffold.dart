import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/search/cubit/hs_main_search_cubit.dart';
import 'package:hitspot/features/search/view/main_search_delegate.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class HSScaffold extends StatelessWidget {
  const HSScaffold({
    super.key,
    this.topSafe = true,
    this.bottomSafe = true,
    this.sidePadding = 16.0,
    this.appBar,
    required this.body,
    this.ignoring = false,
    this.resizeToAvoidBottomInset = true,
    this.backgroundColor,
    this.bottombar,
    this.defaultBottombarEnabled = false,
    this.floatingActionButton,
    this.onTap,
  });

  final bool topSafe;
  final bool bottomSafe;
  final double sidePadding;
  final Widget? appBar;
  final Widget body;
  final bool ignoring;
  final bool resizeToAvoidBottomInset;
  final Color? backgroundColor;
  final Widget? bottombar;
  final Widget? floatingActionButton;
  final bool defaultBottombarEnabled;
  final VoidCallback? onTap;

  static void hideInput() =>
      SystemChannels.textInput.invokeMethod('TextInput.hide');

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? hideInput,
      child: IgnorePointer(
        ignoring: ignoring,
        child: Scaffold(
          floatingActionButton: floatingActionButton,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar:
              defaultBottombarEnabled ? const _Bottombar() : const SizedBox(),
          backgroundColor: backgroundColor,
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
          body: SafeArea(
            top: topSafe,
            bottom: bottomSafe,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: sidePadding),
              child: Column(
                children: [if (appBar != null) appBar!, Expanded(child: body)],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Bottombar extends StatelessWidget {
  const _Bottombar({super.key, this.height = 60.0, this.color});

  final double height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14.0),
          child: Container(
            height: height,
            color: color ?? appTheme.textfieldFillColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List<_BottombarItem>.from(
                  _BottombarItem.defaultList.map((e) => e)).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottombarItem extends StatelessWidget {
  const _BottombarItem(
      {required this.onPressed,
      required this.iconData,
      this.iconColor,
      this.iconSize});

  final VoidCallback onPressed;
  final IconData iconData;
  final Color? iconColor;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: onPressed,
        icon: Icon(iconData, color: iconColor, size: iconSize));
  }

  /// TODO: Change the values below
  static final List<_BottombarItem> defaultList = [
    _BottombarItem(
      iconData: FontAwesomeIcons.house,
      onPressed: () => print("home"),
      iconColor: appTheme.mainColor,
    ),
    _BottombarItem(
        iconData: FontAwesomeIcons.magnifyingGlass,
        onPressed: () => showSearch(
            context: app.context,
            delegate: MainSearchDelegate(
                BlocProvider.of<HSMainSearchCubit>(app.context)))),
    const _BottombarItem(
        iconData: FontAwesomeIcons.plus,
        iconSize: 36.0,
        onPressed: _showCreateMenu),
    _BottombarItem(
      iconData: FontAwesomeIcons.bookmark,
      onPressed: () => navi.push("/saved"),
    ),
    _BottombarItem(
      iconData: FontAwesomeIcons.user,
      onPressed: navi.toCurrentUser,
    ),
  ];

  static void _showCreateMenu() {
    showMaterialModalBottomSheet(
      context: app.context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (_) => const _CreateMenu(),
    );
  }
}

class _CreateMenu extends StatelessWidget {
  const _CreateMenu();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(.0, 16.0, .0, 0.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: IconButton(
                        padding: const EdgeInsets.all(0.0),
                        onPressed: navi.pop,
                        icon: const Icon(FontAwesomeIcons.xmark)),
                  ),
                  const Expanded(
                    flex: 3,
                    child: Center(
                      child: Text("Start creating",
                          style: TextStyle(fontSize: 20)),
                    ),
                  ),
                  const Expanded(
                    child: SizedBox(),
                  ),
                ],
              ),
              const Gap(16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _CreateOption(
                    title: "Spot",
                    iconData: FontAwesomeIcons.mapPin,
                    onTap: () {
                      navi.pop();
                      navi.toCreateSpot();
                    },
                  ),
                  const Gap(16.0),
                  _CreateOption(
                    title: "Board",
                    iconData: FontAwesomeIcons.grip,
                    onTap: () {
                      navi.pop();
                      navi.toCreateBoard();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateOption extends StatelessWidget {
  const _CreateOption(
      {required this.title, required this.iconData, required this.onTap});

  final String title;
  final IconData iconData;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100.0,
      child: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(8.0),
            child:
                IconButton(icon: Icon(iconData, size: 24.0), onPressed: onTap),
          ),
          const Gap(4.0),
          Text(title,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              )),
        ],
      ),
    );
  }
}
