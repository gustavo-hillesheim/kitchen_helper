import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/common/common.dart';
import 'package:kitchen_helper/modules/recipes/presenter/screen/recipes_list/widgets/recipe_list_tile.dart';
import 'package:kitchen_helper/modules/recipes/recipes.dart';

void main() {
  testWidgets('SHOULD display basic recipe info', (tester) async {
    const recipe = ListingRecipeDto(
      id: 1,
      name: 'Chocolate topping',
      measurementUnit: MeasurementUnit.milliliters,
      quantityProduced: 650,
    );
    var tapped = false;
    void onTap() => tapped = true;

    await tester.pumpWidget(
      MaterialApp(home: RecipeListTile(recipe, onTap: onTap)),
    );

    // Name
    expect(find.text('Chocolate topping'), findsOneWidget);
    // Quantity produced
    expect(find.textContaining('650'), findsOneWidget);
    // Measurement unit
    expect(find.textContaining(recipe.measurementUnit.label), findsOneWidget);

    expect(tapped, false);
    await tester.tap(find.byType(RecipeListTile));
    expect(tapped, true);
  });

  testWidgets(
      'WHEN rendering a recipe that can be sold '
      'SHOULD display selling info', (tester) async {
    const recipe = ListingRecipeDto(
      id: 2,
      name: 'Cake',
      measurementUnit: MeasurementUnit.units,
      quantityProduced: 2,
      quantitySold: 1,
      price: 50,
    );

    await tester.pumpWidget(
      MaterialApp(home: RecipeListTile(recipe, onTap: () {})),
    );

    // Name
    expect(find.text('Cake'), findsOneWidget);
    // Quantity produced
    expect(find.textContaining('2'), findsOneWidget);
    // Quantity sold
    expect(find.textContaining('1'), findsOneWidget);
    // Measurement unit, one for quantity produced and another for quantity sold
    expect(find.textContaining(recipe.measurementUnit.label), findsNWidgets(2));
    // Price
    expect(
        find.textContaining(Formatter.currency(recipe.price!)), findsOneWidget);
  });
}
