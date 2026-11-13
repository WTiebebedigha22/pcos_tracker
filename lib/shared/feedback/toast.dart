import 'package:flutter/material.dart';

class Toast {
  static void show(BuildContext c, String message, {SnackBarAction? action, bool error = false}) {
    ScaffoldMessenger.of(c)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: error ? Theme.of(c).colorScheme.error : null,
        action: action,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ));
  }

  static void undo(BuildContext c, String message, VoidCallback onUndo) =>
      show(c, message, action: SnackBarAction(label: 'Undo', onPressed: onUndo));
}
