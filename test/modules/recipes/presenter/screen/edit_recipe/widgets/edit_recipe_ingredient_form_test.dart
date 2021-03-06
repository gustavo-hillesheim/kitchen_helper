import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/common/common.dart';
import 'package:kitchen_helper/modules/recipes/presenter/screen/edit_recipe/models/editing_recipe_ingredient.dart';
import 'package:kitchen_helper/modules/recipes/presenter/screen/edit_recipe/widgets/edit_recipe_ingredient_form.dart';
import 'package:kitchen_helper/modules/recipes/recipes.dart';

import '../../../../../../finders.dart';
import '../../../../../../mocks.dart';

void main() {
  setUp(() {
    mockRecipeIngredientsSelectorService();
  });

  testWidgets('SHOULD render main elements', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EditRecipeIngredientForm(
            onSave: (_) {},
            onCancel: () {},
          ),
        ),
      ),
    );

    expect(find.byType(RecipeIngredientSelector), findsOneWidget);
    expect(
      AppTextFormFieldFinder(
        name: 'Quantidade',
        type: TextInputType.number,
      ),
      findsOneWidget,
    );
    expect(find.byType(PrimaryButton), findsOneWidget);
    expect(find.text('Adicionar'), findsOneWidget);
    expect(find.text('Adicionar ingrediente'), findsOneWidget);
  });

  testWidgets(
      'WHEN initialValue is provided SHOULD render elements with values',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EditRecipeIngredientForm(
            onSave: (_) {},
            onCancel: () {},
            initialValue: const EditingRecipeIngredient(
              id: 1,
              name: 'Ingredient',
              type: RecipeIngredientType.ingredient,
              quantity: 10,
              measurementUnit: MeasurementUnit.kilograms,
              cost: 10,
            ),
          ),
        ),
      ),
    );

    expect(
      AppTextFormFieldFinder(
        name: MeasurementUnit.kilograms.label,
        type: TextInputType.number,
        value: '10',
      ),
      findsOneWidget,
    );
    expect(find.text('Ingredient'), findsOneWidget);
    expect(find.text('Editar ingrediente'), findsOneWidget);
  });

  testWidgets('WHEN save is tapped AND has values SHOULD call onSave',
      (tester) async {
    RecipeIngredient? value;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EditRecipeIngredientForm(
            onSave: (savedValue) => value = savedValue,
            onCancel: () {},
          ),
        ),
      ),
    );

    // Selects ingredient
    await tester.tap(find.byType(RecipeIngredientSelector));
    await tester.pumpAndSettle();
    await tester.tap(find.text(egg.name));
    await tester.pumpAndSettle();

    // Inputs quantity
    await tester.enterText(
      AppTextFormFieldFinder(
        name: egg.measurementUnit.label,
        type: TextInputType.number,
      ),
      '10',
    );

    await tester.tap(find.text('Adicionar'));

    expect(
      value,
      RecipeIngredient(
        id: egg.id!,
        quantity: 10,
        type: RecipeIngredientType.ingredient,
      ),
    );
  });
}
