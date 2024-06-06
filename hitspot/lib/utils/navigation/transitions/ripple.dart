import 'package:flutter/material.dart';

class RipplePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  RipplePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return RippleTransition(
              animation: animation,
              position: const Offset(0.5, 1.0), // bottom center of the screen
              child: child,
            );
          },
        );
}

class RippleTransition extends StatelessWidget {
  final Animation<double> animation;
  final Offset position;
  final Widget child;

  const RippleTransition({
    super.key,
    required this.animation,
    required this.position,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final screenSize = MediaQuery.of(context).size;
        final center = Offset(
            screenSize.width * position.dx, screenSize.height * position.dy);

        return ClipPath(
          clipper: RippleClipper(animation.value, center),
          child: child,
        );
      },
      child: child,
    );
  }
}

class RippleClipper extends CustomClipper<Path> {
  final double progress;
  final Offset center;

  RippleClipper(this.progress, this.center);

  @override
  Path getClip(Size size) {
    final path = Path();
    final radius = progress * size.longestSide;
    path.addOval(Rect.fromCircle(center: center, radius: radius));
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
