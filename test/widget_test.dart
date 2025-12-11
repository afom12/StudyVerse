// Widget tests for StudyVerse app
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:study_verse/main.dart';

void main() {
  testWidgets('StudyVerse app launches and shows login screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Note: We wrap in ProviderScope since our app uses Riverpod
    await tester.pumpWidget(
      const ProviderScope(
        child: StudyVerseApp(),
      ),
    );

    // Wait for the app to fully load
    await tester.pumpAndSettle();

    // Verify that the login screen appears (check for "Welcome Back" text)
    expect(find.text('Welcome Back'), findsOneWidget);
    
    // Verify that sign in button exists
    expect(find.text('Sign In'), findsOneWidget);
    
    // Verify that sign up link exists
    expect(find.text('Sign Up'), findsOneWidget);
  });

  testWidgets('Login screen has email and password fields', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: StudyVerseApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify email field exists
    expect(find.byIcon(Icons.email_outlined), findsOneWidget);
    
    // Verify password field exists
    expect(find.byIcon(Icons.lock_outlined), findsWidgets);
  });
}
