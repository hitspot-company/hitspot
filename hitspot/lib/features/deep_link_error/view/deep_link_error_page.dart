import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_button.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';

class DeepLinkErrorPage extends StatelessWidget {
  const DeepLinkErrorPage({super.key, this.title, this.message, this.icon});

  final String? title, message;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return HSScaffold(
      appBar: HSAppBar(
        titleText: title ?? 'Error',
        enableDefaultBackButton: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon ?? Icons.error_outline, color: Colors.red, size: 48)
                .animate()
                .fadeIn(duration: 300.ms, curve: Curves.easeInOut)
                .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
            const Gap(16),
            Text(
              message ?? 'Something went wrong.',
              style: textTheme.headlineSmall,
            ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
            const Gap(16),
            HSButton(
              onPressed: () => navi.go("/"),
              child: const Text("Home"),
            )
                .animate()
                .fadeIn(duration: 300.ms, delay: 200.ms)
                .slideY(begin: 0.2, end: 0),
          ],
        ),
      ),
    );
  }
}
