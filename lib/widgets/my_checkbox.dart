import 'package:flutter/material.dart';

class MyCheckbox extends StatefulWidget {
  const MyCheckbox({
    super.key,
    required this.selected,
    required this.onChange,
  });

  final bool selected;
  final Function(bool? value) onChange;
  @override
  State<MyCheckbox> createState() => _MyCheckboxState();
}

class _MyCheckboxState extends State<MyCheckbox> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Color getColor(Set<WidgetState> states) {
      const Set<WidgetState> interactiveStates = <WidgetState>{
        WidgetState.pressed,
        WidgetState.hovered,
        WidgetState.focused,
      };
      if (states.isNotEmpty) {
        return Colors.blue;
      }

      return Theme.of(context).colorScheme.outlineVariant;
    }

    return Checkbox(
      checkColor: Colors.white,
      fillColor: WidgetStateProperty.resolveWith(getColor),
      value: widget.selected,
      onChanged: widget.onChange,
      // onChanged: (bool? value) {
      //   setState(() {
      //     isChecked = value!;
      //   });
      // },
    );
  }
}
