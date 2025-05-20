import 'package:flutter/material.dart';

class LoadingProgress extends StatelessWidget {
  const LoadingProgress({
    super.key,
    this.bgColor,
    this.surfaceColor,
  });

  final Color? bgColor;
  final Color? surfaceColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgColor ??
          Theme.of(context).colorScheme.surfaceContainer.withAlpha(100),
      child: Center(
        child: AlertDialog(
          backgroundColor:
              surfaceColor ?? Theme.of(context).colorScheme.surface,
          content: const SizedBox(
            width: 50.0, // Sesuaikan dengan lebar yang Anda inginkan
            height: 50.0, // Sesuaikan dengan tinggi yang Anda inginkan
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ),
    );
  }
}
