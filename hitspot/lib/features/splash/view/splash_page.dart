import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:lottie/lottie.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late final AnimationController _controller;
  final String animation = "assets/splash/splash_right.json";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.addListener(_listenAndNavigate);
  }

  @override
  void dispose() {
    _controller.removeListener(_listenAndNavigate);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HSScaffold(
      backgroundColor: appTheme.mainColor,
      body: Lottie.asset(
        controller: _controller,
        frameRate: const FrameRate(60),
        onLoaded: (composition) {
          _controller.duration = composition.duration;
          _controller.forward();
        },
        animation,
      ),
    );
  }

  void _listenAndNavigate() {
    if (_controller.isCompleted) {
      app.authenticationBloc.initializeStreamSubscription();
    }
  }
}
