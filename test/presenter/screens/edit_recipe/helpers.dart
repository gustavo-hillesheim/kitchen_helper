import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/core/core.dart';
import 'package:kitchen_helper/domain/domain.dart';
import 'package:kitchen_helper/presenter/presenter.dart';
import 'package:kitchen_helper/presenter/screens/edit_recipe/edit_recipe_bloc.dart';
import 'package:kitchen_helper/presenter/screens/edit_recipe/models/editing_recipe_ingredient.dart';
import 'package:kitchen_helper/presenter/widgets/recipe_ingredient_selector.dart';
import 'package:mocktail/mocktail.dart';
import 'package:modular_test/modular_test.dart';

import '../../../mocks.dart';
import '../../finders.dart';

final quantityProducedFieldFinder = AppTextFormFieldFinder(
  name: 'Quantidade produzida',
  type: TextInputType.number,
);
final measurementUnitSelectorFinder = find.byType(MeasurementUnitSelector);
final notesFieldFinder = AppTextFormFieldFinder(name: 'Anotações');
final canBeSoldFieldFinder = find.byType(CheckboxListTile);
final quantitySoldFieldFinder = AppTextFormFieldFinder(
  name: 'Quantidade vendida',
  type: TextInputType.number,
);
final priceFieldFinder = AppTextFormFieldFinder(
  name: 'Preço de venda',
  type: TextInputType.number,
  prefix: 'R\$',
);

void mockProfitCalculation(
    EditRecipeBloc bloc, double profitPerQuantitySold, double totalProfit) {
  when(() => bloc.calculateProfitPerQuantitySold(
        quantityProduced: any(named: 'quantityProduced'),
        quantitySold: any(named: 'quantitySold'),
        pricePerQuantitySold: any(named: 'pricePerQuantitySold'),
        totalCost: any(named: 'totalCost'),
      )).thenAnswer((_) => profitPerQuantitySold);
  when(() => bloc.calculateTotalProfit(
        quantityProduced: any(named: 'quantityProduced'),
        quantitySold: any(named: 'quantitySold'),
        pricePerQuantitySold: any(named: 'pricePerQuantitySold'),
        totalCost: any(named: 'totalCost'),
      )).thenAnswer((_) => totalProfit);
}

Future<void> fillGeneralInformationForm(
  WidgetTester tester, {
  bool? canBeSold,
  String? notes,
  MeasurementUnit? measurementUnit,
  double? quantityProduced,
  double? quantitySold,
  double? price,
}) async {
  if (canBeSold ?? false) {
    await tester.tap(canBeSoldFieldFinder);
    await tester.pumpAndSettle();
  }
  if (quantityProduced != null) {
    await tester.enterText(
        quantityProducedFieldFinder, Formatter.simpleNumber(quantityProduced));
  }
  if (notes != null) {
    await tester.enterText(notesFieldFinder, notes);
  }
  if (quantitySold != null) {
    await tester.enterText(
        quantitySoldFieldFinder, Formatter.simpleNumber(quantitySold));
  }
  if (price != null) {
    await tester.enterText(priceFieldFinder, Formatter.simpleNumber(price));
  }
  if (measurementUnit != null) {
    await tester.tap(measurementUnitSelectorFinder);
    await tester.pumpAndSettle();
    await tester.tap(find.text(measurementUnit.label).last);
    await tester.pumpAndSettle();
  }
}

Future<void> addIngredient(
  WidgetTester tester, {
  double? quantity,
  String? ingredientName,
}) async {
  await tester.tap(find.text('Adicionar ingrediente').last);
  await tester.pump();

  if (quantity != null) {
    await tester.enterText(
      AppTextFormFieldFinder(
        name: 'Quantidade',
        type: TextInputType.number,
      ),
      Formatter.simpleNumber(quantity),
    );
  }
  if (ingredientName != null) {
    await tester.tap(find.byType(RecipeIngredientSelector));
    await tester.pumpAndSettle();
    await tester.tap(find.text(ingredientName));
    await tester.pumpAndSettle();
  }
  await tester.tap(find.text('Salvar').last);
}

void mockRecipeIngredientsSelectorService() {
  registerFallbackValue(const NoParams());
  final getRecipeUseCase = GetRecipeUseCaseMock();
  final getRecipesUseCase = GetRecipesUseCaseMock();
  final getIngredientsUseCase = GetIngredientsUseCaseMock();
  when(() => getRecipeUseCase.execute(any()))
      .thenAnswer((_) async => const Right(null));
  when(() => getIngredientsUseCase.execute(any()))
      .thenAnswer((_) async => const Right([egg]));
  when(() => getRecipesUseCase.execute(any()))
      .thenAnswer((_) async => const Right([]));
  initModule(FakeModule(
    getRecipeUseCase,
    getRecipesUseCase,
    getIngredientsUseCase,
  ));
}

class FakeModule extends Module {
  final GetRecipeUseCase getRecipeUseCase;
  final GetRecipesUseCase getRecipesUseCase;
  final GetIngredientsUseCase getIngredientsUseCase;

  FakeModule(
    this.getRecipeUseCase,
    this.getRecipesUseCase,
    this.getIngredientsUseCase,
  );

  @override
  List<Bind<Object>> get binds => [
        Bind.instance<GetRecipeUseCase>(getRecipeUseCase),
        Bind.instance<GetRecipesUseCase>(getRecipesUseCase),
        Bind.instance<GetIngredientsUseCase>(getIngredientsUseCase),
      ];
}

List<EditingRecipeIngredient> editingRecipeIngredients(Recipe recipe) {
  return recipe.ingredients.map((ingredient) {
    return EditingRecipeIngredient.fromModels(
      ingredient,
      ingredient: ingredientsMap[ingredient.id],
    );
  }).toList();
}
