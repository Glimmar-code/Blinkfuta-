import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../post_model.dart';

/// The Figma file surfaced "Activity" inside a settings bottom-sheet rather
/// than as its own screen. Since your app already has a dedicated "Alerts"
/// nav tab, this promotes that content to a full screen instead.
class NotificationsScreen extends StatelessWidget {
  final bool isDark;
  const NotificationsScreen({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final txt = isDark ? BlinkColors.textDark : BlinkColors.textLight;
    final muted = isDark ? BlinkColors.mutedDark : BlinkColors.mutedLight;
    final border = isDark ? BlinkColors.borderDark : BlinkColors.borderLight;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        Text('Activity', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: txt)),
        const SizedBox(height: 18),
        ...activities.map((a) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  CircleAvatar(radius: 19, backgroundImage: NetworkImage(unsplash(a.avatar))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: 13, color: txt),
                        children: [
                          TextSpan(text: '${a.user} ', style: const TextStyle(fontWeight: FontWeight.w600)),
                          TextSpan(text: a.action, style: TextStyle(color: muted)),
                        ],
                      ),
                    ),
                  ),
                  Text(a.time, style: TextStyle(fontSize: 11, color: muted.withOpacity(0.7))),
                ],
              ),
            )),
        Divider(color: border, height: 32),
        Text('No more notifications', style: TextStyle(fontSize: 12, color: muted), textAlign: TextAlign.center),
      ],
    );
  }
}