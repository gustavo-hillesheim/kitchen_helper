import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/core/core.dart';
import 'package:kitchen_helper/domain/domain.dart';
import 'package:kitchen_helper/presenter/presenter.dart';
import 'package:kitchen_helper/presenter/screens/edit_recipe/models/editing_recipe_ingredient.dart';
import 'package:kitchen_helper/presenter/screens/edit_recipe/widgets/edit_recipe_ingredient_form.dart';
import 'package:kitchen_helper/presenter/screens/edit_recipe/widgets/recipe_ingredient_selector.dart';
import 'package:mocktail/mocktail.dart';
import 'package:modular_test/modular_test.dart';

import '../../../../mocks.dart';
import '../../../finders.dart';

void main() {
  late GetIngredientsUseCase getIngredientsUseCase;
  late GetRecipesUseCase getRecipesUseCase;

  setUp(() {
    registerFallbackValue(const NoParams());
    getRecipesUseCase = GetRecipesUseCaseMock();
    getIngredientsUseCase = GetIngredientsUseCaseMock();
    when(() => getIngredientsUseCase.execute(any()))
        .thenAnswer((_) async => const Right([egg]));
    when(() => getRecipesUseCase.execute(any()))
        .thenAnswer((_) async => const Right([]));
    initModule(FakeModule(getRecipesUseCase, getIngredientsUseCase));
  });

  testWidgets('SHOULD render main elements', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EditRecipeIngredientForm(onSave: (_) {}),
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
    expect(find.text('Salvar'), findsOneWidget);
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

    await tester.tap(find.text('Salvar'));

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

class FakeModule extends Module {
  final GetRecipesUseCase getRecipesUseCase;
  final GetIngredientsUseCase getIngredientsUseCase;

  FakeModule(this.getRecipesUseCase, this.getIngredientsUseCase);

  @override
  List<Bind<Object>> get binds => [
        Bind.instance<GetRecipesUseCase>(getRecipesUseCase),
        Bind.instance<GetIngredientsUseCase>(getIngredientsUseCase),
      ];
}
