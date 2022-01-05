import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/presenter/screens/menu/widgets/page_description_tile.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../mocks.dart';

void main() {
  const tile = PageDescriptionTile(
    name: 'Test page',
    description: 'This is a description for a test page',
    icon: Icons.add,
    route: '/test-page',
  );

  testWidgets('SHOULD render PageDescriptionTile correctly', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: tile));

    expect(find.text(tile.name), findsOneWidget);
    expect(find.text(tile.description), findsOneWidget);
    expect(find.byIcon(tile.icon), findsOneWidget);
  });

  testWidgets('WHEN tapped should navigate', (tester) async {
    final navigator = mockNavigator();
    when(() => navigator.pushNamed(any())).thenAnswer((_) async => null);

    await tester.pumpWidget(const MaterialApp(home: tile));

    await tester.tap(find.byWidget(tile));

    verify(() => navigator.pushNamed(tile.route));
  });

  testWidgets('WHEN cancel tap SHOULD not navigate', (tester) async {
    final navigator = mockNavigator();
    when(() => navigator.pushNamed(any())).thenAnswer((_) async => null);

    await tester.pumpWidget(const MaterialApp(home: tile));

    final gesture = await tester.createGesture();
    await gesture.down(
      tester.getCenter(find.byWidget(tile)),
      timeStamp: const Duration(milliseconds: 100),
    );
    await gesture.cancel(timeStamp: const Duration(milliseconds: 100));

    verifyNever(() => navigator.pushNamed(tile.route));
  });
}
