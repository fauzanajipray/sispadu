import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

class ImageRect extends StatelessWidget {
  const ImageRect(
    this.src,
    this.name, {
    this.headers,
    this.fontSize = 14,
    this.radius = 4.0,
    this.roundTopOnly = false,
    super.key,
  });

  final String? src;
  final String? name;
  final double fontSize;
  final double radius;
  final Map<String, String>? headers;
  final bool roundTopOnly;

  @override
  Widget build(BuildContext context) {
    final borderRadius = roundTopOnly
        ? BorderRadius.vertical(
            top: Radius.circular(radius),
            bottom: const Radius.circular(0),
          )
        : BorderRadius.circular(radius);

    return ClipRRect(
      borderRadius: borderRadius,
      child: src != null && src!.isNotEmpty
          ? ExtendedImage.network(
              src!,
              headers: headers,
              fit: BoxFit.cover,
              cache: true,
              clearMemoryCacheWhenDispose: true,
              loadStateChanged: (ExtendedImageState state) {
                if (state.extendedImageLoadState == LoadState.loading) {
                  // Custom loading progress widget
                  return Container(
                    color: Theme.of(context).colorScheme.surface.withAlpha(200),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (state.extendedImageLoadState == LoadState.failed) {
                  // Fallback widget for failed image loading
                  return Container(
                    color: Theme.of(context).colorScheme.secondary,
                    child: Center(
                      child: Text(
                        name != null
                            ? name!.length == 1
                                ? name!.toUpperCase()
                                : name!.substring(0, 2).toUpperCase()
                            : 'EE',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSecondary,
                          fontSize: fontSize,
                        ),
                      ),
                    ),
                  );
                }

                // Default behavior for successfully loaded images
                return null;
              },
            )
          : Container(
              color: Theme.of(context).colorScheme.secondary,
              child: Center(
                child: Text(
                  name != null
                      ? name!.length == 1
                          ? name!.toUpperCase()
                          : name!.substring(0, 2).toUpperCase()
                      : 'EE',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondary,
                    fontSize: fontSize,
                  ),
                ),
              ),
            ),
    );
  }
}
