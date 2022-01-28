import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/domain/domain.dart';
import 'package:kitchen_helper/presenter/presenter.dart';
import 'package:kitchen_helper/presenter/screens/ingredients_list/widgets/ingredient_list_tile.dart';

import '../../../../mocks.dart';

void main() {
  testWidgets('Should render Ingredient data correctly', (tester) async {
    bool tapped = false;
    void onTap() {
      tapped = true;
    }

    final tile = IngredientListTile(listingEggDto, onTap: onTap);
    await tester.pumpWidget(MaterialApp(
      home: tile,
    ));

    expect(find.text(listingEggDto.name), findsOneWidget);
    expect(find.text(Formatter.currency(listingEggDto.cost)), findsOneWidget);
    expect(
      find.text(
          '${Formatter.simpleNumber(listingEggDto.quantity)} ${listingEggDto.measurementUnit.label}'),
      findsOneWidget,
    );

    await tester.tap(find.byWidget(tile));

    expect(tapped, true);
  });
}
