// lib/widgets/retro_button.dart
import 'package:flutter/material.dart';

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
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    this.backgroundColor = Colors.transparent,
    this.borderColor = Colors.transparent,
    this.borderWidth = 0,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onTap != null;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: padding,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isEnabled
                ? [const Color(0xFF83B5F1), const Color(0xFF4A88D7)]
                : [const Color(0xFFC0C0C0), const Color(0xFFA0A0A0)],
          ),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: isEnabled
                ? const Color(0xFF3B6DA9).withOpacity(0.8)
                : const Color(0xFF888888),
            width: 1.0,
          ),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    offset: const Offset(0, 3),
                    blurRadius: 5,
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 3,
                  ),
                ]
              : null,
        ),
        // DefaultTextStyle ensures any child Text without a style gets this styling.
        child: DefaultTextStyle.merge(
          style: theme.textTheme.labelLarge!.copyWith(
            color: isEnabled ? Colors.white : Colors.white70,
            fontWeight: FontWeight.w600,
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}
