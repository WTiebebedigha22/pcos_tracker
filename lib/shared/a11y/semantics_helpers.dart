import 'package:flutter/material.dart';

/// Wrap icon-only buttons so screen readers announce intent.
class AccessibleIconButton extends StatelessWidget {
  const AccessibleIconButton({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    button: true,
    enabled: onPressed != null,
    child: IconButton(
      icon: Icon(icon),
      tooltip: tooltip ?? label,
      onPressed: onPressed,
    ),
  );
}

/// Min 48dp tap target wrapper for custom widgets.
class MinTapTarget extends StatelessWidget {
  const MinTapTarget({super.key, required this.child, this.onTap, this.label});
  final Widget child;
  final VoidCallback? onTap;
  final String? label;

  @override
  Widget build(BuildContext context) => Semantics(
    label: label, button: onTap != null,
    child: ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      child: InkWell(onTap: onTap, child: Center(child: child)),
    ),
  );
}
