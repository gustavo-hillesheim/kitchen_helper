import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/common/common.dart';
import 'package:kitchen_helper/common/widget/recipe_ingredient_selector_service.dart';
import 'package:kitchen_helper/core/core.dart';
import 'package:kitchen_helper/modules/ingredients/ingredients.dart';
import 'package:kitchen_helper/modules/recipes/recipes.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks.dart';

void main() {
  late RecipeIngredientSelectorService service;
  late GetRecipesDomainUseCase getRecipesUseCase;
  late GetIngredientsUseCase getIngredientsUseCase;

  setUp(() {
    registerFallbackValue(const RecipeFilter());
    getRecipesUseCase = GetRecipesDomainUseCaseMock();
    getIngredientsUseCase = GetIngredientsUseCaseMock();
    service = RecipeIngredientSelectorService(
      getRecipesUseCase,
      getIngredientsUseCase,
    );
  });

  test('WHEN call getItems SHOULD return both recipes and ingredients',
      () async {
    when(() => getRecipesUseCase.execute(any())).thenAnswer(
      (_) async => const Right([cakeRecipeDomain, sugarWithEggRecipeDomain]),
    );
    when(() => getIngredientsUseCase.execute(null)).thenAnswer(
      (_) async => const Right([
        listingSugarDto,
        listingEggDto,
        listingFlourDto,
      ]),
    );

    final result = await service.getItems();

    expect(result.isRight(), true);
    expect(
      result.getRight().toNullable(),
      _selectorItems(
        [cakeRecipe, egg, flour, sugarWithId, sugarWithEggRecipeWithId],
      ),
    );
  });

  test('WHEN recipeToIgnore is provided SHOULD not return that recipe',
      () async {
    when(() => getRecipesUseCase.execute(any())).thenAnswer(
      (_) async => const Right([sugarWithEggRecipeDomain]),
    );
    when(() => getIngredientsUseCase.execute(null)).thenAnswer(
      (_) async =>
          const Right([listingSugarDto, listingEggDto, listingFlourDto]),
    );

    final result = await service.getItems(recipeToIgnore: cakeRecipe.id);
    expect(
      result.getRight().toNullable(),
      _selectorItems([egg, flour, sugarWithId, sugarWithEggRecipeWithId]),
    );
    verify(() => getRecipesUseCase
        .execute(RecipeDomainFilter(ignoreRecipesThatDependOn: cakeRecipe.id)));
  });

  test(
      'WHEN recipeToIgnore is provided SHOULD not return recipes that '
      'contain that recipe', () async {
    when(() => getRecipesUseCase.execute(any()))
        .thenAnswer((_) async => const Right([]));
    when(() => getIngredientsUseCase.execute(null)).thenAnswer((_) async =>
        const Right([listingSugarDto, listingEggDto, listingFlourDto]));

    final result = await service.getItems(
      recipeToIgnore: sugarWithEggRecipeWithId.id,
    );

    expect(
      result.getRight().toNullable(),
      _selectorItems([egg, flour, sugarWithId]),
    );
    verify(() => getRecipesUseCase.execute(RecipeDomainFilter(
        ignoreRecipesThatDependOn: sugarWithEggRecipeWithId.id)));
  });

  test('WHEN getOnly is recipes SHOULD only call getRecipesUseCase', () async {
    when(() => getRecipesUseCase.execute(any())).thenAnswer(
      (_) async => const Right([cakeRecipeDomain, sugarWithEggRecipeDomain]),
    );

    final result = await service.getItems(
      getOnly: RecipeIngredientSelectorItems.recipes,
    );

    expect(
      result.getRight().toNullable(),
      _selectorItems([cakeRecipe, sugarWithEggRecipeWithId]),
    );
  });

  test('WHEN getOnly is ingredients SHOULD only call getIngredientsUseCase',
      () async {
    when(() => getIngredientsUseCase.execute(null)).thenAnswer(
      (_) async =>
          const Right([listingSugarDto, listingEggDto, listingFlourDto]),
    );

    final result = await service.getItems(
      getOnly: RecipeIngredientSelectorItems.ingredients,
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
