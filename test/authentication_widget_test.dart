import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:huge_learning_platform/features/authentication/presentation/pages/login_page.dart';
import 'package:huge_learning_platform/features/authentication/presentation/pages/register_page.dart';
import 'package:huge_learning_platform/features/authentication/presentation/pages/register_address_page.dart';
import 'package:huge_learning_platform/features/authentication/presentation/widgets/login_form.dart';
import 'package:huge_learning_platform/features/authentication/presentation/widgets/register_biographic_form.dart';
import 'package:huge_learning_platform/features/authentication/presentation/widgets/register_address_form.dart';

void main() {
  group('Authentication Widget Tests', () {
    testWidgets('TC-LOGIN-UI-001: Login form displays correctly', (WidgetTester tester) async {
      // Build the login page
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginPage(),
          ),
        ),
      );

      // Verify login form elements are present
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Login'), findsWidgets);
      expect(find.text('Forgot Password?'), findsOneWidget);
    });

    testWidgets('TC-LOGIN-UI-002: Login form validation works', (WidgetTester tester) async {
      // Build the login page
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginPage(),
          ),
        ),
      );

      // Try to submit empty form
      final loginButton = find.text('Login');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Should show validation errors
      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('TC-REG-UI-001: Registration biographic form displays correctly', (WidgetTester tester) async {
      // Build the registration page
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RegisterPage(),
          ),
        ),
      );

      // Verify biographic form elements are present
      expect(find.text('Full Name *'), findsOneWidget);
      expect(find.text('Email *'), findsOneWidget);
      expect(find.text('Phone *'), findsOneWidget);
      expect(find.text('Password *'), findsOneWidget);
      expect(find.text('Date of Birth *'), findsOneWidget);
      expect(find.text('Gender *'), findsOneWidget);
      expect(find.text('Step 1 of 2: Personal Information'), findsOneWidget);
    });

    testWidgets('TC-REG-UI-002: Registration biographic form validation works', (WidgetTester tester) async {
      // Build the registration page
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RegisterPage(),
          ),
        ),
      );

      // Try to submit empty form
      final nextButton = find.text('NEXT: ADDRESS INFORMATION');
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // Should show validation errors
      expect(find.text('Please enter your name'), findsOneWidget);
    });

    testWidgets('TC-REG-UI-003: Registration address form displays correctly', (WidgetTester tester) async {
      // Build the address form with biographic data
      final biographicData = {
        'name': 'Test User',
        'email': 'test@example.com',
        'phone': '+919876543210',
        'password': 'Test@1234',
        'confirmPassword': 'Test@1234',
        'dateOfBirth': '1990-01-01',
        'gender': 'Male',
      };

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: RegisterAddressPage(biographicData: biographicData),
          ),
        ),
      );

      // Verify address form elements are present
      expect(find.text('Address *'), findsOneWidget);
      expect(find.text('City *'), findsOneWidget);
      expect(find.text('State *'), findsOneWidget);
      expect(find.text('Country *'), findsOneWidget);
      expect(find.text('PIN Code *'), findsOneWidget);
      expect(find.text('Step 2 of 2: Address Information'), findsOneWidget);
    });

    testWidgets('TC-REG-UI-004: Registration address form validation works', (WidgetTester tester) async {
      // Build the address form
      final biographicData = {
        'name': 'Test User',
        'email': 'test@example.com',
        'phone': '+919876543210',
        'password': 'Test@1234',
        'confirmPassword': 'Test@1234',
        'dateOfBirth': '1990-01-01',
        'gender': 'Male',
      };

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: RegisterAddressPage(biographicData: biographicData),
          ),
        ),
      );

      // Try to submit empty form
      final registerButton = find.text('CREATE ACCOUNT');
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      // Should show validation errors
      expect(find.text('Please enter your address'), findsOneWidget);
    });

    testWidgets('TC-REG-UI-005: Password visibility toggle works', (WidgetTester tester) async {
      // Build the registration page
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RegisterPage(),
          ),
        ),
      );

      // Find password field
      final passwordField = find.widgetWithText(TextFormField, 'Password *');
      expect(passwordField, findsOneWidget);

      // Find visibility toggle button
      final visibilityButton = find.byIcon(Icons.visibility_outlined);
      expect(visibilityButton, findsWidgets);

      // Tap visibility toggle
      await tester.tap(visibilityButton.first);
      await tester.pumpAndSettle();

      // Should show visibility_off icon
      expect(find.byIcon(Icons.visibility_off_outlined), findsWidgets);
    });
  });
}



