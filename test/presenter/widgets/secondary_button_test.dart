import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/presenter/widgets/secondary_button.dart';

void main() {
  testWidgets('Should render OutlinedButton', (tester) async {
    var called = false;
    void onPressed() {
      called = true;
    }

    await tester.pumpWidget(
      MaterialApp(
        home: SecondaryButton(
          onPressed: onPressed,
          child: const Text('Secondary action'),
        ),
      ),
    );

    final textFinder = find.text('Secondary action');
    expect(find.byType(OutlinedButton), findsOneWidget);
    expect(textFinder, findsOneWidget);
    await tester.tap(textFinder);
    expect(called, true);
  });
}
