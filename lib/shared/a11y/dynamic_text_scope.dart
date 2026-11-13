import 'package:flutter/material.dart';

/// Wrap large screens in this to cap text scale so layout doesn't break
/// (still respects user preference up to a point).
class DynamicTextScope extends StatelessWidget {
  const DynamicTextScope({super.key, required this.child, this.max = 1.6});
  final Widget child;
  final double max;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return MediaQuery(
      data: mq.copyWith(textScaler: TextScaler.linear(mq.textScaler.scale(1).clamp(1.0, max))),
      child: child,
    );
  }
}
