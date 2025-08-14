// widgets/formatted_text.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FormattedText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color? defaultColor;
  final FontWeight? fontWeight;

  const FormattedText({
    super.key,
    required this.text,
    this.fontSize = 16,
    this.defaultColor,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    final lines = text.split('\n');
    final List<TextSpan> spans = [];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      
      if (line.trim().startsWith('>')) {
        // Greentext line
        spans.add(
          TextSpan(
            text: line,
            style: GoogleFonts.vt323(
              fontSize: fontSize,
              color: const Color(0xFF789922), // Classic greentext color
              fontWeight: fontWeight,
            ),
          ),
        );
      } else {
        // Regular text line
        spans.add(
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

    return RichText(
      text: TextSpan(children: spans),
      softWrap: true,
    );
  }
}
