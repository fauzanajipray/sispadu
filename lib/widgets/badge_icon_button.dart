import 'package:flutter/material.dart';

class BadgeIconButton extends StatefulWidget {
  final IconData iconData;
  final int itemCount;
  final VoidCallback onPressed;

  const BadgeIconButton({
    super.key,
    this.iconData = Icons.shopping_cart,
    required this.itemCount,
    required this.onPressed,
  });

  @override
  State<BadgeIconButton> createState() => _BadgeIconButtonState();
}

class _BadgeIconButtonState extends State<BadgeIconButton> {
  @override
  Widget build(BuildContext context) {
    String itemCountText = widget.itemCount > 99 ? '∞' : '${widget.itemCount}';

    return IconButton(
      icon: Stack(
        children: <Widget>[
          Icon(widget.iconData),
          if (widget.itemCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.error,
                ),
                constraints: const BoxConstraints(
                  minWidth: 14,
                  minHeight: 14,
                ),
                child: Text(
                  itemCountText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      onPressed: widget.onPressed,
    );
  }
}
