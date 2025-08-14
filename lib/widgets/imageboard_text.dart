// widgets/imageboard_text.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  List<TextSpan> _parseText(String text) {
    final lines = text.split('\n');
    final List<TextSpan> spans = [];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      spans.addAll(_parseLine(line));

      // Add newline except for the last line
      if (i < lines.length - 1) {
        spans.add(
          TextSpan(
            text: '\n',
            style: GoogleFonts.vt323(fontSize: fontSize),
          ),
        );
      }
    }

    return spans;
  }

  List<TextSpan> _parseLine(String line) {
    final List<TextSpan> lineSpans = [];

    // Check for greentext (lines starting with >)
    if (line.trim().startsWith('>')) {
      lineSpans.add(
        TextSpan(
          text: line,
          style: GoogleFonts.vt323(
            fontSize: fontSize,
            color: const Color(0xFF789922), // Classic 4chan green
            fontWeight: fontWeight,
          ),
        ),
      );
      return lineSpans;
    }

    // Parse the line for other formatting
    final RegExp boldRegex = RegExp(r'\*\*(.*?)\*\*');
    final RegExp italicRegex = RegExp(r'\*(.*?)\*');
    final RegExp codeRegex = RegExp(r'`(.*?)`');
    final RegExp quoteRegex = RegExp(r'>>(\d+)');

    int lastIndex = 0;
    String remainingText = line;

    // Find all formatting matches
    final allMatches = <MapEntry<int, Match>>[];
    
    for (final match in boldRegex.allMatches(line)) {
      allMatches.add(MapEntry(match.start, match));
    }
    for (final match in italicRegex.allMatches(line)) {
      allMatches.add(MapEntry(match.start, match));
    }
    for (final match in codeRegex.allMatches(line)) {
      allMatches.add(MapEntry(match.start, match));
    }
    for (final match in quoteRegex.allMatches(line)) {
      allMatches.add(MapEntry(match.start, match));
    }

    // Sort matches by position
    allMatches.sort((a, b) => a.key.compareTo(b.key));

    for (final entry in allMatches) {
      final match = entry.value;
      
      // Add text before this match
      if (match.start > lastIndex) {
        lineSpans.add(
          TextSpan(
            text: line.substring(lastIndex, match.start),
            style: GoogleFonts.vt323(
              fontSize: fontSize,
              color: defaultColor ?? Colors.black,
              fontWeight: fontWeight,
            ),
          ),
        );
      }

      // Add the formatted match
      if (boldRegex.hasMatch(match.group(0)!)) {
        lineSpans.add(
          TextSpan(
            text: match.group(1),
            style: GoogleFonts.vt323(
              fontSize: fontSize,
              color: defaultColor ?? Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      } else if (italicRegex.hasMatch(match.group(0)!) && !boldRegex.hasMatch(match.group(0)!)) {
        lineSpans.add(
          TextSpan(
            text: match.group(1),
            style: GoogleFonts.vt323(
              fontSize: fontSize,
              color: defaultColor ?? Colors.black,
              fontStyle: FontStyle.italic,
              fontWeight: fontWeight,
            ),
          ),
        );
      } else if (codeRegex.hasMatch(match.group(0)!)) {
        lineSpans.add(
          TextSpan(
            text: match.group(1),
            style: GoogleFonts.vt323(
              fontSize: fontSize - 2,
              color: const Color(0xFF333333),
              backgroundColor: const Color(0xFFF0F0F0),
              fontWeight: fontWeight,
            ),
          ),
        );
      } else if (quoteRegex.hasMatch(match.group(0)!)) {
        lineSpans.add(
          TextSpan(
            text: match.group(0),
            style: GoogleFonts.vt323(
              fontSize: fontSize,
              color: const Color(0xFF0066CC), // Blue for post quotes
              fontWeight: fontWeight,
              decoration: TextDecoration.underline,
            ),
          ),
        );
      }

      lastIndex = match.end;
    }

    // Add remaining text
    if (lastIndex < line.length) {
      lineSpans.add(
        TextSpan(
          text: line.substring(lastIndex),
          style: GoogleFonts.vt323(
            fontSize: fontSize,
            color: defaultColor ?? Colors.black,
            fontWeight: fontWeight,
          ),
        ),
      );
    }

    // If no formatting was found, return the whole line as regular text
    if (lineSpans.isEmpty) {
      lineSpans.add(
        TextSpan(
          text: line,
          style: GoogleFonts.vt323(
            fontSize: fontSize,
            color: defaultColor ?? Colors.black,
            fontWeight: fontWeight,
          ),
        ),
      );
    }

    return lineSpans;
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(children: _parseText(text)),
      softWrap: true,
    );
  }
}
