import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huge_learning_platform/main.dart';

void main() {
  testWidgets('App builds successfully', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    // Verify app builds without errors
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('Home page renders', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    // Verify home page title
    expect(find.text('Namaste! 🙏'), findsOneWidget);
  });
}
