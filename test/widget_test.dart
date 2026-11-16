import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Basic MaterialApp render test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Ration Attendance System'),
          ),
        ),
      ),
    );
    expect(find.text('Ration Attendance System'), findsOneWidget);
  });
}
