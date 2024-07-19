import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/widgets/hs_image.dart';
import 'package:hs_database_repository/hs_database_repository.dart';

class HSSpotCard extends StatelessWidget {
  final HSSpot spot;
  final int index;

  const HSSpotCard({super.key, required this.spot, required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => navi.toSpot(sid: spot.sid!),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: HSImage(
                  imageUrl: spot.images!.first,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    spot.title!,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  AutoSizeText(
                    "${spot.likesCount} likes • ${spot.commentsCount} comments",
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms, delay: (50 * index).ms),
    );
  }
}
