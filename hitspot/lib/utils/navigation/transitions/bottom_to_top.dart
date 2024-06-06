import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomToTopPage<T> extends CustomTransitionPage<T> {
  @override
  final Widget child;

  BottomToTopPage({required this.child})
      : super(
          transitionDuration: const Duration(milliseconds: 300),
          child: child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeIn;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        );
}
