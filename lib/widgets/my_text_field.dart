import 'package:flutter/material.dart';

enum TextFieldType { password, email, normal, number, none }

class MyTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? initialValue;
  final String hintText;
  final String? labelText;
  final String? errorText;
  final TextFieldType type;
  final bool obscureText;
  final Icon? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onEditingComplete;
  final VoidCallback? onTap;
  final Function(String value)? onChange;
  final Function(String? value)? validator;
  final FocusNode? focusNode;
  final bool filled;
  final bool readOnly;
  final Color? textColor;
  final TextStyle? hintStyle;
  final Color? borderColor;
  final Iterable<String>? autofillHints;

  const MyTextField({
    Key? key,
    required this.controller,
    this.initialValue,
    this.labelText,
    this.hintText = '',
    this.errorText,
    this.type = TextFieldType.normal,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.focusNode,
    this.onEditingComplete,
    this.filled = true,
    this.textColor,
    this.hintStyle,
    this.onChange,
    this.validator,
    this.readOnly = false,
    this.onTap,
    this.borderColor, // Default border color
    this.autofillHints,
  }) : super(key: key);

  @override
  MyTextFieldState createState() => MyTextFieldState();
}

class MyTextFieldState extends State<MyTextField> {
  bool obscureState = false;
  late Color borderColor;

  @override
  void initState() {
    super.initState();
    obscureState = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    Widget? suffixIcon;
    borderColor = widget.borderColor ?? Theme.of(context).colorScheme.outline;
    if (widget.obscureText) {
      suffixIcon = IconButton(
        onPressed: () {
          setState(() {
            obscureState = !obscureState;
          });
        },
        icon: Icon(
          obscureState
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
        ),
      );
    } else if (widget.suffixIcon != null) {
      suffixIcon = widget.suffixIcon;
    }
    TextInputType? inputType;
    if (widget.type == TextFieldType.email) {
      inputType = TextInputType.emailAddress;
    } else if (widget.type == TextFieldType.password) {
      inputType = TextInputType.visiblePassword;
    } else if (widget.type == TextFieldType.number) {
      inputType = TextInputType.number;
    } else if (widget.type == TextFieldType.none) {
      inputType = TextInputType.none;
    } else {
      inputType = TextInputType.text;
    }
    return _pointer(inputType, suffixIcon);
  }

  Widget _pointer(TextInputType? inputType, Widget? suffixIcon) {
    if (inputType == TextInputType.none) {
      return InkWell(
        onTap: widget.onTap,
        child: IgnorePointer(
          child: textFormField(inputType, suffixIcon),
        ),
      );
    }
    return textFormField(inputType, suffixIcon);
  }

  Widget textFormField(TextInputType? inputType, Widget? suffixIcon) {
    return TextFormField(
      initialValue: widget.initialValue,
      autofillHints: widget.autofillHints,
      controller: widget.controller,
      keyboardType: inputType,
      obscureText: obscureState,
      validator: (value) {
        if (widget.validator != null) {
          return widget.validator!(value);
        } else {
          return null;
        }
      },
      readOnly: widget.readOnly,
      focusNode: widget.focusNode,
      onChanged: (value) {
        if (widget.onChange != null) {
          widget.onChange!(value);
        }
      },
      onEditingComplete: widget.onEditingComplete,
      onTap: widget.onTap,
      style: TextStyle(
        color: widget.textColor ?? Theme.of(context).colorScheme.onSurface,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(color: borderColor), // Use borderColor here
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(color: borderColor.withOpacity(0.8)),
        ),
        filled: widget.filled,
        labelText: widget.labelText,
        hintText: widget.hintText,
        hintStyle: widget.hintStyle, // Corrected hintStyle assignment
        errorText: widget.errorText,
        errorMaxLines: 3,
        suffixIcon: suffixIcon,
        prefixIcon: widget.prefixIcon,
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
