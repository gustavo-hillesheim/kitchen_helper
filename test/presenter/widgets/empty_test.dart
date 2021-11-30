import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/presenter/widgets/empty.dart';

void main() {
  testWidgets('Should render default Empty correctly', (tester) async {
    await tester
        .pumpWidget(const MaterialApp(home: Empty(text: 'This is empty')));

    expect(find.byIcon(Icons.no_food_outlined), findsOneWidget);
    expect(find.text('This is empty'), findsOneWidget);
  });
  testWidgets('Should render customized Empty correctly', (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: Empty(
      text: 'This is empty again',
      subtext: 'This is a subtext',
      action: Text('Am I an action?'),
      icon: Icons.error,
    )));

    expect(find.byIcon(Icons.error), findsOneWidget);
    expect(find.text('This is empty again'), findsOneWidget);
    expect(find.text('This is a subtext'), findsOneWidget);
    expect(find.text('Am I an action?'), findsOneWidget);
  });
}
