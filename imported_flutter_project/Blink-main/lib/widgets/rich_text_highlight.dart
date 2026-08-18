import 'package:flutter/material.dart';
import '../../config/theme.dart';

/// Renders [text] with @mentions and #hashtags highlighted in accent color.
/// Direct port of the Figma `RichText` helper.
class RichTextHighlight extends StatelessWidget {
  final String text;
  final Color color;
  final double fontSize;
  final FontWeight fontWeight;
  final double? height;

  const RichTextHighlight({
    super.key,
    required this.text,
    this.color = Colors.white,
    this.fontSize = 13,
    this.fontWeight = FontWeight.normal,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final pattern = RegExp(r'(@\w+|#\w+)');
    final spans = <TextSpan>[];
    var start = 0;
    for (final match in pattern.allMatches(text)) {
      if (match.start > start) {
        spans.add(TextSpan(text: text.substring(start, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(0),
        style: const TextStyle(color: BlinkColors.accent, fontWeight: FontWeight.w600),
      ));
      start = match.end;
    }
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return Text.rich(
      TextSpan(
        style: TextStyle(color: color, fontSize: fontSize, fontWeight: fontWeight, height: height),
        children: spans,
      ),
    );
  }
}