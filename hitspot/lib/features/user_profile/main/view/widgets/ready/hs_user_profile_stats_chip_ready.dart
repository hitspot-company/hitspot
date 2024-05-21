import 'package:flutter/material.dart';
import 'package:hitspot/constants/constants.dart';

class HSUserProfileStatsChipReady extends StatelessWidget {
  const HSUserProfileStatsChipReady(
      {super.key, required this.label, this.value});

  final String label;
  final int? value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Text(label, style: textTheme.headlineSmall),
          Text('${value ?? 0}', style: textTheme.headlineSmall),
        ],
      ),
    );
  }
}
