import 'package:flutter/material.dart';

enum ScreenSize { compact, medium, expanded }

class Responsive extends StatelessWidget {
  const Responsive({
    super.key,
    required this.compact,
    this.medium,
    this.expanded,
  });

  final WidgetBuilder compact;
  final WidgetBuilder? medium;
  final WidgetBuilder? expanded;

  static ScreenSize of(BuildContext c) {
    final w = MediaQuery.sizeOf(c).width;
    if (w < 600) return ScreenSize.compact;
    if (w < 1024) return ScreenSize.medium;
    return ScreenSize.expanded;
  }

  @override
  Widget build(BuildContext c) {
    switch (of(c)) {
      case ScreenSize.compact: return compact(c);
      case ScreenSize.medium: return (medium ?? compact)(c);
      case ScreenSize.expanded: return (expanded ?? medium ?? compact)(c);
    }
  }
}
