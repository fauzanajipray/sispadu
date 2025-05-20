import 'package:flutter/material.dart';

class UiText extends StatefulWidget {
  const UiText(
      {Key? key,
      this.style,
      this.textAlign,
      this.text,
      this.span,
      this.maxLines})
      : super(key: key);
  final String? text;
  final TextSpan? span;
  final TextAlign? textAlign;
  final TextStyle? style;
  final int? maxLines;

  @override
  State<UiText> createState() => _UiTextState();
}

class _UiTextState extends State<UiText> {
  final FocusNode _focusNode = FocusNode(skipTraversal: true);
  @override
  Widget build(BuildContext context) {
    if (widget.span != null) {
      return SelectableText.rich(widget.span!,
          textAlign: widget.textAlign,
          style: widget.style,
          focusNode: _focusNode,
          maxLines: widget.maxLines);
    } else {
      return SelectableText(widget.text ?? "",
          textAlign: widget.textAlign,
          style: widget.style,
          focusNode: _focusNode,
          maxLines: widget.maxLines);
    }
  }
}
