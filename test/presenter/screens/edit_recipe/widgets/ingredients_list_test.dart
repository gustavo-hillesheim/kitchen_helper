import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/domain/domain.dart';
import 'package:kitchen_helper/presenter/presenter.dart';
import 'package:kitchen_helper/presenter/screens/edit_recipe/models/editing_recipe_ingredient.dart';
import 'package:kitchen_helper/presenter/screens/edit_recipe/widgets/ingredients_list.dart';
import 'package:kitchen_helper/presenter/widgets/secondary_button.dart';

import '../../../../mocks.dart';
import '../helpers.dart';

void main() {
  setUp(() {
    mockRecipeIngredientsSelectorService();
  });

  testWidgets('WHEN have ingredients SHOULD render them', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: IngredientsList(
        editingRecipeIngredients(sugarWithEggRecipeWithId),
        onAdd: (_) {},
        onEdit: (_, __) {},
        onDelete: (_) {},
      ),
    ));

    expect(find.byType(IngredientListTile), findsNWidgets(2));
    expect(find.byType(ActionsSlider), findsNWidgets(2));
    expect(find.byType(SecondaryButton), findsOneWidget);
  });

  testWidgets('WHEN adding new ingredient SHOULD call onAdd', (tester) async {
    var onAddedCalled = false;
    await tester.pumpWidget(MaterialApp(
      home: IngredientsList(
        const [],
        onAdd: (_) => onAddedCalled = true,
        onEdit: (_, __) {},
        onDelete: (_) {},
      ),
    ));

    await tester.tap(find.byType(SecondaryButton));
    await tester.pump();

    await addIngredient(tester, quantity: 10, ingredientName: egg.name);

    expect(onAddedCalled, true);
  });

  testWidgets('WHEN editing ingredient SHOULD call onEdit', (tester) async {
    var onEditCalled = false;
    await tester.pumpWidget(MaterialApp(
      home: IngredientsList(
        editingRecipeIngredients(sugarWithEggRecipeWithId),
        onAdd: (_) {},
        onEdit: (_, __) => onEditCalled = true,
        onDelete: (_) {},
      ),
    ));

    await tester.tap(find.text(egg.name));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar'));

    expect(onEditCalled, true);
  });

  group('IngredientListTile', () {
    testWidgets('SHOULD render ingredient info', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: IngredientListTile(EditingRecipeIngredient(
          id: 1,
          name: 'Ingrediente',
          quantity: 15,
          type: RecipeIngredientType.ingredient,
          measurementUnit: MeasurementUnit.milliliters,
          cost: 500,
        )),
      ));

      expect(find.text('Ingrediente'), findsOneWidget);
      expect(
        find.text('15 ${MeasurementUnit.milliliters.abbreviation}'),
        findsOneWidget,
      );
      expect(find.text('R\$500.00'), findsOneWidget);
    });
  });
}
