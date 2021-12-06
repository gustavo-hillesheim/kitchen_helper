import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/presenter/screens/menu/widgets/page_description_tile.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../mocks.dart';

void main() {
  testWidgets('Should render PageDescriptionTile correctly', (tester) async {
    final navigator = mockNavigator();

    const tile = PageDescriptionTile(
      name: 'Test page',
      description: 'This is a description for a test page',
      icon: Icons.add,
      route: '/test-page',
    );
    await tester.pumpWidget(const MaterialApp(home: tile));

    when(() => navigator.pushNamed(any())).thenAnswer((_) async => null);

    expect(find.text('Test page'), findsOneWidget);
    expect(find.text('This is a description for a test page'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);

    await tester.tap(find.byWidget(tile));

    verify(() => navigator.pushNamed('/test-page'));
  });
}
