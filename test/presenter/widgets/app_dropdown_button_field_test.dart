import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/presenter/presenter.dart';

void main() {
  testWidgets('SHOULD create items according to values', (tester) async {
    final widget = AppDropdownButtonField<Values>(
      name: 'Test',
      onChange: (_) {},
      values: const {
        'Value A': Values.A,
        'Value B': Values.B,
        'Value C': Values.C,
      },
    );
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

    await tester.tap(find.byWidget(widget));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Value A'), findsOneWidget);
    expect(find.text('Value B'), findsOneWidget);
    expect(find.text('Value C'), findsOneWidget);
  });
}

enum Values { A, B, C }
