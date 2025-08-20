// lib/widgets/imageboard_text.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

        return RichText(
          text: TextSpan(children: _parseText(text, adjustedFontSize)),
          softWrap: true,
          overflow: TextOverflow.clip,
        );
      },
    );
  }

  List<TextSpan> _parseText(String text, double fontSize) {
    final lines = text.split('\n');
    final spans = <TextSpan>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.trim().startsWith('>')) {
        spans.add(
          TextSpan(
            text: line + (i < lines.length - 1 ? '\n' : ''),
            style: GoogleFonts.vt323(
              color: const Color(0xFF789922),
              fontSize: fontSize,
              fontWeight: fontWeight,
            ),
          ),
        );
      } else {
        spans.addAll(_parseInlineFormatting(line, fontSize));
        if (i < lines.length - 1) {
          spans.add(const TextSpan(text: '\n'));
        }
      }
    }
    return spans;
  }

  List<TextSpan> _parseInlineFormatting(String text, double fontSize) {
    final spans = <TextSpan>[];
    int currentIndex = 0;

    final regex = RegExp(r'(\*\*.+?\*\*|\*.+?\*|`.+?`|>>\d+)', multiLine: true);

    final matches = regex.allMatches(text).toList();

    for (final match in matches) {
      if (match.start > currentIndex) {
        spans.add(
          TextSpan(
            text: text.substring(currentIndex, match.start),
            style: _normalStyle(fontSize),
          ),
        );
      }

      final matchText = match.group(0)!;

      if (matchText.startsWith('**')) {
        spans.add(
          TextSpan(
            text: matchText.substring(2, matchText.length - 2),
            style: GoogleFonts.vt323(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: defaultColor ?? Colors.black,
            ),
          ),
        );
      } else if (matchText.startsWith('*')) {
        spans.add(
          TextSpan(
            text: matchText.substring(1, matchText.length - 1),
            style: GoogleFonts.vt323(
              fontSize: fontSize,
              fontStyle: FontStyle.italic,
              color: defaultColor ?? Colors.black,
            ),
          ),
        );
      } else if (matchText.startsWith('`')) {
        spans.add(
          TextSpan(
            text: matchText.substring(1, matchText.length - 1),
            style: GoogleFonts.vt323(
              fontSize: fontSize * 0.9,
              backgroundColor: const Color(0xFFF0F0F0),
              color: Colors.black87,
            ),
          ),
        );
      } else if (matchText.startsWith('>>')) {
        spans.add(
          TextSpan(
            text: matchText,
            style: GoogleFonts.vt323(
              fontSize: fontSize,
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
        );
      } else {
        spans.add(TextSpan(text: matchText, style: _normalStyle(fontSize)));
      }

      currentIndex = match.end;
    }

    if (currentIndex < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(currentIndex),
          style: _normalStyle(fontSize),
        ),
      );
    }

    if (spans.isEmpty) {
      spans.add(TextSpan(text: text, style: _normalStyle(fontSize)));
    }

    return spans;
  }

  TextStyle _normalStyle(double fontSize) {
    return GoogleFonts.vt323(
      fontSize: fontSize,
      color: defaultColor ?? Colors.black,
      fontWeight: fontWeight,
    );
  }
}
