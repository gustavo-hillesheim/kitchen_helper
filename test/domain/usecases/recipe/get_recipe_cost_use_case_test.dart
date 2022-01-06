import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/domain/domain.dart';
import 'package:mocktail/mocktail.dart';

import '../../../mocks.dart';

void main() {
  late GetRecipeCostUseCase usecase;
  late RecipeRepository recipeRepository;
  late IngredientRepository ingredientRepository;

  setUp(() {
    recipeRepository = RecipeRepositoryMock();
    ingredientRepository = IngredientRepositoryMock();
    usecase = GetRecipeCostUseCase(recipeRepository, ingredientRepository);
  });

  void mockFindRecipes() {
    when(() => recipeRepository.findById(any())).thenAnswer((invocation) async {
      final id = invocation.positionalArguments[0] as int;
      return Right({
        1: recipeWithIngredients,
        2: recipeWithRecipeAndIngredients,
      }[id]);
    });
  }

  void mockFindIngredients() {
    when(() => ingredientRepository.findById(any()))
        .thenAnswer((invocation) async {
      final id = invocation.positionalArguments[0] as int;
      return Right({
        1: ingredientOne,
        2: ingredientTwo,
        3: ingredientThree,
      }[id]);
    });
  }

  test(
      'WHEN recipe has only ingredients '
      'SHOULD calculate it\'s cost correctly', () async {
    mockFindRecipes();
    mockFindIngredients();

    final result = await usecase.execute(recipeWithIngredients);

    // 2 from ingredient one and 5 from ingredient two
    expect(result.getRight().toNullable(), 7);
  });

  test(
      'WHEN recipe has other recipes and ingredients '
      'SHOULD calculate it\'s cost correctly', () async {
    mockFindRecipes();
    mockFindIngredients();

    final result = await usecase.execute(recipeWithRecipeAndIngredients);

    // 35 from recipe and 37.5 from ingredient three
    expect(result.getRight().toNullable(), 72.5);
  });
}
