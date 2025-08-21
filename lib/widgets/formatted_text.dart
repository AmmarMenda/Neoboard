// lib/widgets/imageboard_text.dart
import 'package:flutter/material.dart';

class ImageboardText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final Color? defaultColor;
  final FontWeight? fontWeight;

  const ImageboardText({
    super.key,
    required this.text,
    this.fontSize,
    this.defaultColor,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Establish a base style from the theme.
    // This will automatically use the "Lora" serif font.
    final baseStyle = theme.textTheme.bodyMedium!.copyWith(
      fontSize: fontSize, // Allow optional override for font size
      color:
          defaultColor ??
          theme.textTheme.bodyMedium!.color, // Allow color override
      fontWeight: fontWeight, // Allow font weight override
    );

    // Define the style for ">" quote lines, making it a more theme-appropriate green.
    final quoteStyle = baseStyle.copyWith(
      color: const Color(0xFF5A8E5A), // A muted, classic greentext color
    );

    final lines = text.split('\n');
    final List<TextSpan> spans = [];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      if (line.trim().startsWith('>')) {
        spans.add(TextSpan(text: line, style: quoteStyle));
      } else {
        spans.add(TextSpan(text: line, style: baseStyle));
      }

      // Add the newline character back. It will inherit the default style.
      if (i < lines.length - 1) {
        spans.add(const TextSpan(text: '\n'));
      }
    }

    // Use RichText to render the styled spans.
    return RichText(
      text: TextSpan(
        // Set the base style on the parent TextSpan so all children inherit it by default.
        style: baseStyle,
        children: spans,
      ),
      softWrap: true,
    );
  }
}
