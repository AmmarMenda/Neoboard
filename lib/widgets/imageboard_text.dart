// lib/widgets/imageboard_text.dart
import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';

class ImageboardText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color? defaultColor;
  final FontWeight? fontWeight;

  const ImageboardText({
    super.key,
    required this.text,
    this.fontSize = 16,
    this.defaultColor,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    // This part of your logic for responsive font sizing is excellent and remains.
    return LayoutBuilder(
      builder: (context, constraints) {
        double adjustedFontSize = ResponsiveHelper.getFontSize(
          context,
          fontSize,
        );
        if (constraints.maxWidth < 300) {
          adjustedFontSize *= 0.8;
        } else if (constraints.maxWidth < 400) {
          adjustedFontSize *= 0.9;
        }

        // We pass the context down to the parsing functions so they can access the theme.
        return RichText(
          text: TextSpan(
            // Set a default style on the parent to ensure all children inherit the correct font.
            style: _normalStyle(context, adjustedFontSize),
            children: _parseText(context, text, adjustedFontSize),
          ),
          softWrap: true,
          overflow: TextOverflow.clip,
        );
      },
    );
  }

  // *** THEMED PARSING LOGIC ***

  List<TextSpan> _parseText(
    BuildContext context,
    String text,
    double fontSize,
  ) {
    final lines = text.split('\n');
    final spans = <TextSpan>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.trim().startsWith('>')) {
        // Style for ">" greentext lines
        spans.add(
          TextSpan(
            text: line + (i < lines.length - 1 ? '\n' : ''),
            // Use a muted green that fits the theme
            style: _normalStyle(
              context,
              fontSize,
            ).copyWith(color: const Color(0xFF5A8E5A)),
          ),
        );
      } else {
        spans.addAll(_parseInlineFormatting(context, line, fontSize));
        if (i < lines.length - 1) {
          spans.add(const TextSpan(text: '\n'));
        }
      }
    }
    return spans;
  }

  List<TextSpan> _parseInlineFormatting(
    BuildContext context,
    String text,
    double fontSize,
  ) {
    final theme = Theme.of(context);
    final spans = <TextSpan>[];
    int currentIndex = 0;
    // Your regex for parsing is good and remains unchanged.
    final regex = RegExp(r'(\*\*.+?\*\*|\*.+?\*|`.+?`|>>\d+)', multiLine: true);
    final matches = regex.allMatches(text).toList();

    // Helper styles derived from the base theme style
    final baseStyle = _normalStyle(context, fontSize);
    final boldStyle = baseStyle.copyWith(fontWeight: FontWeight.bold);
    final italicStyle = baseStyle.copyWith(fontStyle: FontStyle.italic);
    final codeStyle = baseStyle.copyWith(
      fontSize: fontSize * 0.9,
      backgroundColor: theme.dividerColor.withOpacity(0.5),
      color: theme.colorScheme.onSurface.withOpacity(0.8),
    );
    final linkStyle = baseStyle.copyWith(
      color:
          theme.colorScheme.primary, // Use the theme's primary blue for links
      decoration: TextDecoration.underline,
    );

    for (final match in matches) {
      if (match.start > currentIndex) {
        spans.add(
          TextSpan(
            text: text.substring(currentIndex, match.start),
            style: baseStyle,
          ),
        );
      }
      final matchText = match.group(0)!;

      // Apply themed styles based on the match
      if (matchText.startsWith('**')) {
        spans.add(
          TextSpan(
            text: matchText.substring(2, matchText.length - 2),
            style: boldStyle,
          ),
        );
      } else if (matchText.startsWith('*')) {
        spans.add(
          TextSpan(
            text: matchText.substring(1, matchText.length - 1),
            style: italicStyle,
          ),
        );
      } else if (matchText.startsWith('`')) {
        spans.add(
          TextSpan(
            text: matchText.substring(1, matchText.length - 1),
            style: codeStyle,
          ),
        );
      } else if (matchText.startsWith('>>')) {
        spans.add(TextSpan(text: matchText, style: linkStyle));
      }
      currentIndex = match.end;
    }
    if (currentIndex < text.length) {
      spans.add(TextSpan(text: text.substring(currentIndex), style: baseStyle));
    }
    if (spans.isEmpty) {
      spans.add(TextSpan(text: text, style: baseStyle));
    }
    return spans;
  }

  // *** THEMED BASE STYLE ***
  // This is the most important change. It creates a base style from the theme.
  TextStyle _normalStyle(BuildContext context, double fontSize) {
    // Start with the theme's default body text style (which has the correct serif font)
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
      fontSize: fontSize,
      color: defaultColor ?? Theme.of(context).textTheme.bodyMedium!.color,
      fontWeight: fontWeight,
    );
  }
}
