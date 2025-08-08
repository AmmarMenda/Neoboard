import 'package:flutter/material.dart';

enum RetroPanelType { raised, sunken }

class RetroPanel extends StatelessWidget {
  final Widget child;
  final RetroPanelType type;
  final EdgeInsets padding;

  const RetroPanel({
    super.key,
    required this.child,
    this.type = RetroPanelType.raised,
    this.padding = const EdgeInsets.all(8.0),
  });

  @override
  Widget build(BuildContext context) {
    final Border border = type == RetroPanelType.raised
        ? Border(
            top: BorderSide(color: Colors.white, width: 2),
            left: BorderSide(color: Colors.white, width: 2),
            right: BorderSide(color: Colors.grey[800]!, width: 2),
            bottom: BorderSide(color: Colors.grey[800]!, width: 2),
          )
        : Border(
            top: BorderSide(color: Colors.black, width: 2),
            left: BorderSide(color: Colors.black, width: 2),
            right: BorderSide(color: Colors.white, width: 2),
            bottom: BorderSide(color: Colors.white, width: 2),
          );

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xFFC0C0C0), // Classic grey
        border: border,
      ),
      child: child,
    );
  }
}
