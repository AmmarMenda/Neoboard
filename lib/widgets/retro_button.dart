// lib/widgets/retro_button.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RetroButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;

  const RetroButton({
    super.key,
    required this.onTap,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.backgroundColor = const Color(0xFFE0E0E0),
    this.borderColor = Colors.black,
    this.borderWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onTap != null;

    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: padding,
        decoration: BoxDecoration(
          color: isEnabled ? backgroundColor : backgroundColor.withOpacity(0.5),
          border: Border.all(color: borderColor, width: borderWidth),
          boxShadow: isEnabled
              ? const [
                  BoxShadow(
                    color: Colors.black54,
                    offset: Offset(4, 4),
                    blurRadius: 0,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: DefaultTextStyle(
          style: GoogleFonts.vt323(
            color: isEnabled ? Colors.black : Colors.black38,
            fontSize: 20,
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}
