import 'package:flutter/material.dart';

class TextBadge extends StatelessWidget {
  final Text text;
  final Color color;
  final double horizontalPadding;
  final double verticalPadding;

  const TextBadge({
    super.key,
    required this.text,
    required this.color,
    this.horizontalPadding = 12,
    this.verticalPadding = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding, vertical: verticalPadding),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: text);
  }
}
