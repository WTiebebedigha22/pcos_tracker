import 'package:flutter/material.dart';

enum AppButtonVariant { primary, secondary, ghost, danger }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.loading = false,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool loading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
        : Row(mainAxisSize: MainAxisSize.min, children: [
            if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
            Text(label),
          ]);
    final btn = switch (variant) {
      AppButtonVariant.primary => FilledButton(onPressed: loading ? null : onPressed, child: child),
      AppButtonVariant.secondary => OutlinedButton(onPressed: loading ? null : onPressed, child: child),
      AppButtonVariant.ghost => TextButton(onPressed: loading ? null : onPressed, child: child),
      AppButtonVariant.danger => FilledButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
        ).let((s) => FilledButton(style: s, onPressed: loading ? null : onPressed, child: child)),
    };
    return expand ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}

extension _Let<T> on T { R let<R>(R Function(T) f) => f(this); }
