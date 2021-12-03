import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/domain/models/measurement_unit.dart';
import 'package:kitchen_helper/presenter/screens/ingredients_list/widgets/ingredient_list_tile.dart';
import 'package:kitchen_helper/presenter/utils/formatter.dart';

import '../../../../mocks.dart';

void main() {
  testWidgets('Should render Ingredient data correctly', (tester) async {
    bool tapped = false;
    void onTap() {
      tapped = true;
    }

    final tile = IngredientListTile(egg, onTap: onTap);
    await tester.pumpWidget(MaterialApp(
      home: tile,
    ));

    expect(find.text(egg.name), findsOneWidget);
    expect(find.text(Formatter.price(egg.price)), findsOneWidget);
    expect(
      find.text(
          '${Formatter.simple(egg.quantity)} ${egg.measurementUnit.label}'),
      findsOneWidget,
    );

    await tester.tap(find.byWidget(tile));

    expect(tapped, true);
  });
}
