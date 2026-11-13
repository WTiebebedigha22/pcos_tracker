import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pump a screen and call this to assert every tappable ≥48dp.
/// Usage: await expectMinTapTargets(tester);
Future<void> expectMinTapTargets(WidgetTester tester) async {
  final tappables = find.byWidgetPredicate((w) =>
      w is InkWell || w is IconButton || w is FilledButton || w is TextButton || w is OutlinedButton);
  for (final el in tappables.evaluate()) {
    final box = el.renderObject as RenderBox?;
    if (box == null || !box.hasSize) continue;
    final size = box.size;
    expect(size.width >= 47.0 && size.height >= 47.0, isTrue,
      reason: 'Tappable below 48dp: ${el.widget.runtimeType} ${size.width}x${size.height}');
  }
}
