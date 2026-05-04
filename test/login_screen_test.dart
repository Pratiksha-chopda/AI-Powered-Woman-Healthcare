// --- File: test/login_screen_test.dart ---
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:woman1/main.dart';

void main() {
  testWidgets('Login screen UI test', (WidgetTester tester) async {
    // Pump the root widget from main.dart
    await tester.pumpWidget(const OvacareApp()); // ✅ Correct class

    // ✅ Check that the welcome text is shown
    expect(find.text('Welcome Back'), findsOneWidget);

    // ✅ Check that the subtitle is present
    expect(find.text('Login to continue your health journey'), findsOneWidget);

    // ✅ Check that Email + Password fields exist
    expect(find.byType(TextField), findsNWidgets(2));

    // ✅ Check that Login button is present
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
  });
}
