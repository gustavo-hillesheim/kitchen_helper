import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/core/core.dart';
import 'package:kitchen_helper/domain/domain.dart';
import 'package:mocktail/mocktail.dart';

import '../../../mocks.dart';

void main() {
  late GetRecipesUseCase usecase;
  late RecipeRepository recipeRepository;
  late RecipeIngredientRepository recipeIngredientRepository;

  setUp(() {
    recipeRepository = RecipeRepositoryMock();
    recipeIngredientRepository = RecipeIngredientRepositoryMock();
    usecase = GetRecipesUseCase(recipeRepository, recipeIngredientRepository);
  });

  void mockFindIngredients(
      List<Either<Failure, List<RecipeIngredientEntity>>> responses) {
    var index = 0;
    when(() => recipeIngredientRepository.findByRecipe(any()))
        .thenAnswer((_) async => responses[index++]);
  }

  void mockFindRecipes(Either<Failure, List<Recipe>> response) {
    when(() => recipeRepository.findAll()).thenAnswer((_) async => response);
  }

  List<RecipeIngredientEntity> getIngredientEntities(Recipe recipe) {
    return recipe.ingredients
        .map((i) => RecipeIngredientEntity.fromModels(recipe, i))
        .toList(growable: false);
  }

  test(
    'WHEN use case is called '
    'SHOULD return all recipes with their ingredients',
    () async {
      mockFindIngredients([
        Right(getIngredientEntities(sugarWithEggRecipeWithId)),
        Right(getIngredientEntities(cakeRecipe)),
      ]);
      mockFindRecipes(Right([
        sugarWithEggRecipeWithId.copyWith(ingredients: []),
        cakeRecipe.copyWith(ingredients: []),
      ]));

      final result = await usecase.execute(const NoParams());

      expect(result.getRight().toNullable(),
          [sugarWithEggRecipeWithId, cakeRecipe]);

      verify(() => recipeRepository.findAll());
    },
  );

  test(
      'WHEN a Failure is returned from recipeIngredientsRepository '
      'THEN usecase should return it too', () async {
    mockFindIngredients([
      Right(getIngredientEntities(cakeRecipe)),
      Left(FakeFailure('an error')),
    ]);
    mockFindRecipes(Right([
      cakeRecipe.copyWith(ingredients: []),
      sugarWithEggRecipeWithId.copyWith(ingredients: []),
    ]));

    final result = await usecase.execute(const NoParams());

    expect(result.getLeft().toNullable(), FakeFailure('an error'));
    verify(() => recipeRepository.findAll());
    verify(() => recipeIngredientRepository.findByRecipe(cakeRecipe.id!));
    verify(() =>
        recipeIngredientRepository.findByRecipe(sugarWithEggRecipeWithId.id!));
  });

  test(
      'WHEN a Failure is returned from recipeRepository '
      'THEN usecase SHOULD return it too', () async {
    mockFindRecipes(Left(FakeFailure('some error')));

    final result = await usecase.execute(const NoParams());

    expect(result.getLeft().toNullable(), FakeFailure('some error'));
    verify(() => recipeRepository.findAll());
  });
}
