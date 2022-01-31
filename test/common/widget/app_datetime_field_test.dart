import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:kitchen_helper/common/common.dart';

void main() {
  testWidgets('SHOULD render DateTimeField', (tester) async {
    DateTime? value;
    void onChange(DateTime? newValue) {
      value = newValue;
    }

    final widget = AppDateTimeField(
      name: 'Test',
      onChanged: onChange,
    );
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

    await tester.tap(find.byWidget(widget));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    final now = DateTime.now();
    expect(value, DateTime(now.year, now.month, 1, now.hour, now.minute));
  });

  testWidgets('WHEN have initialValue SHOULD render it', (tester) async {
    final now = DateTime.now();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppDateTimeField(
            name: 'Test',
            onChanged: (_) {},
            initialValue: now,
            required: false,
          ),
        ),
      ),
    );

    expect(
      find.text(DateFormat('dd/MM/yyyy HH:mm').format(now)),
      findsOneWidget,
    );
  });
}
