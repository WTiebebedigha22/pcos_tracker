import 'package:flutter/material.dart';
import '../../core/theme/design_tokens.dart';

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.onTap, this.padding});
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignTokens.radius.lg),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(DesignTokens.space.lg),
        child: child,
      ),
    ),
  );
}
