import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/common/common.dart';

void main() {
  testWidgets('SHOULD render label', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Tag(
        label: 'Test',
        color: Colors.red,
        backgroundColor: Colors.blue,
      ),
    ));

    expectTag(
      label: 'Test',
      backgroundColor: Colors.blue,
      foregroundColor: Colors.red,
    );
  });
}

expectTag({
  required String label,
  required Color backgroundColor,
  required Color foregroundColor,
}) {
  expect(
      find.byWidgetPredicate(
        (widget) {
          if (widget is! Container || widget.decoration is! BoxDecoration) {
            return false;
          }
          final decoration = widget.decoration as BoxDecoration;
          return decoration.color == backgroundColor &&
              decoration.border?.bottom.color == foregroundColor;
        },
        description: 'Container(color: $backgroundColor, borderColor: '
            '$foregroundColor)',
      ),
      findsOneWidget);
  expect(
      find.byWidgetPredicate((widget) {
        if (widget is! Text || widget.style == null) {
          return false;
        }
        return widget.data == label && widget.style!.color == foregroundColor;
      }, description: 'Text($label, color: $foregroundColor)'),
      findsOneWidget);
}
