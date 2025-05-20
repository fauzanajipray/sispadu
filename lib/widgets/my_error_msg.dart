import 'package:flutter/material.dart';

class MyErrorMsg extends StatelessWidget {
  final String msg;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;
  final EdgeInsets paddingWrapper;
  final double fontSize;
  final double paddingBox;

  const MyErrorMsg({
    Key? key,
    required this.msg,
    this.paddingBox = 12,
    this.paddingWrapper = const EdgeInsets.fromLTRB(0, 0, 0, 10),
    this.backgroundColor,
    this.borderColor,
    this.textColor,
    this.fontSize = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: paddingWrapper,
        child: Container(
          decoration: BoxDecoration(
              color: backgroundColor ??
                  Theme.of(context).colorScheme.errorContainer,
              border: Border.all(
                color: borderColor ??
                    Theme.of(context)
                        .colorScheme
                        .onErrorContainer
                        .withOpacity(0.2), // Use the borderColor property here
                width: 1.0,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(5)),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: paddingBox,
              vertical: paddingBox,
            ),
            child: Text(
              msg,
              style: TextStyle(
                color:
                    textColor ?? Theme.of(context).colorScheme.onErrorContainer,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ));
  }
}
