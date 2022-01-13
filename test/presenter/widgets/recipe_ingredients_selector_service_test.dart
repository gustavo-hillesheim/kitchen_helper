import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/core/core.dart';
import 'package:kitchen_helper/domain/domain.dart';
import 'package:kitchen_helper/presenter/widgets/recipe_ingredient_selector.dart';
import 'package:kitchen_helper/presenter/widgets/recipe_ingredient_selector_service.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks.dart';

void main() {
  late RecipeIngredientSelectorService service;
  late GetRecipeUseCase getRecipeUseCase;
  late GetRecipesUseCase getRecipesUseCase;
  late GetIngredientsUseCase getIngredientsUseCase;

  setUp(() {
    getRecipeUseCase = GetRecipeUseCaseMock();
    getRecipesUseCase = GetRecipesUseCaseMock();
    getIngredientsUseCase = GetIngredientsUseCaseMock();
    service = RecipeIngredientSelectorService(
      getRecipeUseCase,
      getRecipesUseCase,
      getIngredientsUseCase,
    );
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

  test('WHEN recipeToIgnore is provided SHOULD not return that recipe',
      () async {
    when(() => getRecipeUseCase.execute(any())).thenAnswer((invocation) async {
      final recipeId = invocation.positionalArguments[0];
      return Right(recipesMap[recipeId]);
    });
    when(() => getRecipesUseCase.execute(const NoParams())).thenAnswer(
      (_) async => Right([cakeRecipe, recipeWithIngredients]),
    );
    when(() => getIngredientsUseCase.execute(const NoParams())).thenAnswer(
      (_) async => const Right([sugarWithId, egg, flour]),
    );

    final result = await service.getItems(recipeToIgnore: cakeRecipe.id);
    expect(
      result.getRight().toNullable(),
      _selectorItems([egg, flour, recipeWithIngredients, sugarWithId]),
    );
  });

  test(
      'WHEN recipeToIgnore is provided SHOULD not return recipes that '
      'contain that recipe', () async {
    when(() => getRecipeUseCase.execute(any())).thenAnswer((invocation) async {
      final recipeId = invocation.positionalArguments[0];
      return Right(recipesMap[recipeId]);
    });
    when(() => getRecipesUseCase.execute(const NoParams())).thenAnswer(
      (_) async => Right([cakeRecipe, sugarWithEggRecipeWithId]),
    );
    when(() => getIngredientsUseCase.execute(const NoParams())).thenAnswer(
      (_) async => const Right([sugarWithId, egg, flour]),
    );

    final result = await service.getItems(
      recipeToIgnore: sugarWithEggRecipeWithId.id,
    );

    expect(
      result.getRight().toNullable(),
      _selectorItems([egg, flour, sugarWithId]),
    );
  });
}

List<RecipeIngredientSelectorItem> _selectorItems(List items) {
  return items.map((item) {
    if (item is Ingredient) {
      return RecipeIngredientSelectorItem(
        id: item.id!,
        name: item.name,
        measurementUnit: item.measurementUnit,
        type: RecipeIngredientType.ingredient,
      );
    }
    if (item is Recipe) {
      return RecipeIngredientSelectorItem(
        id: item.id!,
        name: item.name,
        measurementUnit: item.measurementUnit,
        type: RecipeIngredientType.recipe,
      );
    }
    throw Exception('Could not create SelectorItem');
  }).toList();
}
