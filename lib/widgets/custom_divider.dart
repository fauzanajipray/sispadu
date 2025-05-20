import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  const CustomDivider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 8,
      child: Container(
        color: Theme.of(context).colorScheme.surfaceContainer,
      ),
    );
  }
}
