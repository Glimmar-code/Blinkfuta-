import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../config/theme.dart';
import 'package:blink/post_model.dart';

/// Horizontal, Instagram-style story rail. Sits at the top of the feed,
/// above the post list. Kept understated (thin ring, no bounce/scale
/// animation) to match a more professional tone than a bouncy nav bar.
class StoryBar extends StatelessWidget {
  final List<StoryItem> stories;
  final ValueChanged<StoryItem>? onTap;

  const StoryBar({super.key, required this.stories, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: stories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, i) {
          final story = stories[i];
          return GestureDetector(
            onTap: () => onTap?.call(story),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 64,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: story.isOwn || story.isViewed
                          ? null
                          : const LinearGradient(
                              colors: [BlinkColors.accent, Color(0xFF6B8CFF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      border: (story.isOwn || story.isViewed)
                          ? Border.all(color: BlinkColors.divider, width: 1.5)
                          : null,
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: BlinkColors.surfaceRaised,
                          child: Text(
                            story.avatarInitial,
                            style: const TextStyle(
                              color: BlinkColors.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (story.isOwn)
                          Positioned(
                            right: -2,
                            bottom: -2,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: BlinkColors.accent,
                                shape: BoxShape.circle,
                                border: Border.all(color: BlinkColors.surface, width: 2),
                              ),
                              child: const PhosphorIcon(
                                PhosphorIconsBold.plus,
                                size: 11,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    story.isOwn ? 'Your story' : story.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: story.isViewed ? BlinkColors.textMuted : BlinkColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}