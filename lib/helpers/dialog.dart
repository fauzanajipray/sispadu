import 'package:flutter/material.dart';

void showDialogInfo(BuildContext mainContext, Function onYes,
    {String title = 'Info', String? message, String errorBtn = 'Ok'}) {
  bool isDarkMode = Theme.of(mainContext).brightness == Brightness.dark;
  showAdaptiveDialog(
    context: mainContext,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message ?? 'Success'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onYes();
            },
            style: TextButton.styleFrom(
                foregroundColor: isDarkMode
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(context).colorScheme.primary),
            child: Text(errorBtn),
          ),
        ],
      );
    },
  );
}

/// Delete confirmation dialog
///
/// Parameters:
/// - [context] (BuildContext): The context in which the dialog is shown.
/// - [onPositive] (Function): Callback function to execute on positive action.
/// - [title] (String): Title of the dialog.
/// - [message] (String): Message to display in the dialog.
/// - [positiveText] (String): Text for the positive button.
/// - [minusText] (String): Text for the negative button.
/// - [buttonStyleNegative] (ButtonStyle?): Style for the negative button.
/// - [buttonStylePositive] (ButtonStyle?): Style for the positive button.
/// - [onMinus] (Function?): Callback function to execute on negative action.
void showDialogConfirmation(
  BuildContext context,
  Function onPositive, {
  String title = 'Confirmation',
  String message = 'Are you sure you want to delete this data?',
  String positiveText = 'Yes',
  String minusText = 'Cancel',
  ButtonStyle? buttonStyleNegative,
  ButtonStyle? buttonStylePositive,
  Function? onMinus,
}) {
  bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
  showAdaptiveDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            style: buttonStyleNegative ??
                TextButton.styleFrom(
                    foregroundColor: isDarkMode
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context).colorScheme.outline),
            onPressed: () {
              Navigator.of(context).pop();
              onMinus?.call();
            },
            child: Text(minusText),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onPositive();
            },
            style: buttonStylePositive ??
                TextButton.styleFrom(
                    foregroundColor: isDarkMode
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context).colorScheme.error),
            child: Text(positiveText),
          ),
        ],
      );
    },
  );
}

void showDialogMsg(BuildContext mainContext, String errorMessage,
    {String title = 'Error'}) {
  bool isDarkMode = Theme.of(mainContext).brightness == Brightness.dark;
  showAdaptiveDialog(
    context: mainContext,
    builder: (context) => AlertDialog(
      scrollable: true,
      title: Text(title),
      content: Text(errorMessage),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(
            foregroundColor: isDarkMode
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(context).colorScheme.secondary,
          ),
          child: const Text("Close"),
        ),
      ],
    ),
  );
}

showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    ),
  );
}
