import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/core/core.dart';
import 'package:kitchen_helper/domain/domain.dart';
import 'package:kitchen_helper/presenter/screens/edit_recipe/widgets/recipe_ingredient_selector.dart';
import 'package:kitchen_helper/presenter/screens/edit_recipe/widgets/recipe_ingredient_selector_service.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../domain/usecases/recipe/get_recipe_cost_use_case_test.dart';
import '../../../../mocks.dart';

void main() {
  late RecipeIngredientSelectorService service;
  late GetRecipesUseCase getRecipesUseCase;
  late GetIngredientsUseCase getIngredientsUseCase;

  setUp(() {
    getRecipesUseCase = GetRecipesUseCaseMock();
    getIngredientsUseCase = GetIngredientsUseCaseMock();
    service = RecipeIngredientSelectorService(
        getRecipesUseCase, getIngredientsUseCase);
  });

  test('WHEN call getItems SHOULD return both recipes and ingredients',
      () async {
    when(() => getRecipesUseCase.execute(const NoParams())).thenAnswer(
      (_) async => Right([cakeRecipe, recipeWithIngredients]),
    );
    when(() => getIngredientsUseCase.execute(const NoParams())).thenAnswer(
      (_) async => const Right([sugarWithId, egg, flour]),
    );

    final result = await service.getItems();

    expect(result.isRight(), true);
    expect(
      result.getRight().toNullable(),
      _selectorItems(
        [cakeRecipe, egg, flour, recipeWithIngredients, sugarWithId],
      ),
    );
  });
}

List<SelectorItem> _selectorItems(List items) {
  return items.map((item) {
    if (item is Ingredient) {
      return SelectorItem(
        id: item.id!,
        name: item.name,
        measurementUnit: item.measurementUnit,
        type: RecipeIngredientType.ingredient,
      );
    }
    if (item is Recipe) {
      return SelectorItem(
        id: item.id!,
        name: item.name,
        measurementUnit: item.measurementUnit,
        type: RecipeIngredientType.recipe,
      );
    }
    throw Exception('Could not create SelectorItem');
  }).toList();
}
