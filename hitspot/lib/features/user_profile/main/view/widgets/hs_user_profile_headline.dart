import 'package:flutter/material.dart';

class HSUserProfileHeadline extends StatelessWidget {
  const HSUserProfileHeadline({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
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
