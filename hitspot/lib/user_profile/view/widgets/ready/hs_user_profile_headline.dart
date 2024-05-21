import 'package:flutter/material.dart';
import 'package:hitspot/constants/constants.dart';

class HSUserProfileHeadline extends StatelessWidget {
  const HSUserProfileHeadline({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Row(
        children: [
          const SizedBox(
            width: 16.0,
            child: Divider(
              thickness: .1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              title,
              style: textTheme.headlineMedium,
            ),
          ),
          const Expanded(
            child: Divider(
              thickness: .1,
            ),
          ),
        ],
      ),
    );
  }
}
