import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/widgets/spot/hs_better_spot_tile.dart';
import 'package:hs_database_repository/hs_database_repository.dart';

class AnimatedSpotTile extends StatelessWidget {
  const AnimatedSpotTile(
      {super.key, required this.spot, required this.index, this.padding});

  final HSSpot spot;
  final int index;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return HSBetterSpotTile(
      padding: padding,
      onTap: (p0) => navi.toSpot(sid: p0!.sid!),
      borderRadius: BorderRadius.circular(20.0),
      spot: spot,
    ).animate().fadeIn(duration: 300.ms, delay: (50 * index).ms);
  }
}
