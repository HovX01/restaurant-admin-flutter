import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_admin/main.dart';

void main() {
  testWidgets('App starts without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app initializes successfully
    expect(find.byType(MyApp), findsOneWidget);
  });
}
