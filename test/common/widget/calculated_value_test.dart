import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/common/common.dart';

void main() {
  testWidgets(
      'WHEN there are no calculation SHOULD render just title and '
      'value', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
          home: CalculatedValue(
        title: 'Title',
        value: 10,
        calculation: [],
      )),
    );

    expect(find.text('Title'), findsOneWidget);
    expect(find.text('10.00'), findsOneWidget);
  });

  testWidgets('WHEN there are calculations SHOULD render them', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: CalculatedValue(
        title: 'Title',
        value: 10,
        calculation: [
          CalculationStep('First', value: 15),
          CalculationStep('Second', value: -7),
          CalculationStep('Third', value: 2),
        ],
      ),
    ));

    expect(find.text('Title'), findsOneWidget);
    expect(find.text('10.00'), findsOneWidget);
    // First line
    expect(find.text('15.00'), findsOneWidget);
    expect(find.text('First'), findsOneWidget);
    // Second line
    expect(find.text('-'), findsOneWidget);
    expect(find.text('7.00'), findsOneWidget);
    expect(find.text('Second'), findsOneWidget);
    // Third line
    expect(find.text('+'), findsOneWidget);
    expect(find.text('2.00'), findsOneWidget);
    expect(find.text('Third'), findsOneWidget);
  });
}
