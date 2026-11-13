import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lunora/shared/widgets/medical_disclaimer.dart';

void main() {
  testWidgets('renders disclaimer text', (t) async {
    await t.pumpWidget(const MaterialApp(home: Scaffold(body: MedicalDisclaimer())));
    expect(find.textContaining('not a medical device'), findsOneWidget);
  });
}
