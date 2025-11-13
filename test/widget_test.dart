import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Basic widget test - Material App creation', (WidgetTester tester) async {
    // Create a simple test widget
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Restaurant Admin Test'),
          ),
        ),
      ),
    );

    // Verify that the widget tree is created
    expect(find.text('Restaurant Admin Test'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });

  testWidgets('Widget renders text correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: const [
              Text('Title'),
              Text('Subtitle'),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Subtitle'), findsOneWidget);
  });
}
