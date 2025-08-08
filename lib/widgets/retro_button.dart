import 'package:flutter/material.dart';

class RetroButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const RetroButton({
    super.key,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: const Color(0xFFC0C0C0), // Classic grey
          border: Border(
            top: BorderSide(color: Colors.white, width: 2),
            left: BorderSide(color: Colors.white, width: 2),
            right: BorderSide(color: Colors.black, width: 2),
            bottom: BorderSide(color: Colors.black, width: 2),
          ),
        ),
        child: child,
      ),
    );
  }
}
