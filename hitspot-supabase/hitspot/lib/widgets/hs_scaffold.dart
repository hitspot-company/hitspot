import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hitspot/constants/constants.dart';

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

  static void hideInput() =>
      SystemChannels.textInput.invokeMethod('TextInput.hide');

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: hideInput,
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
      // iconColor: currentTheme.mainColor
    ),
    _BottombarItem(
        iconData: FontAwesomeIcons.plane, onPressed: () => print("trips")),
    _BottombarItem(
      iconData: FontAwesomeIcons.plus,
      iconSize: 36.0,
      onPressed: navi.toCreateBoard,
    ),
    _BottombarItem(iconData: FontAwesomeIcons.a, onPressed: () => print("idk")),
    _BottombarItem(
        iconData: FontAwesomeIcons.bookmark,
        onPressed: () => print("saved") // navi.newPush("/saved"),
        ),
  ];
}
