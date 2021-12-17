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

    final result = await usecase.execute(1);

    // 2 from ingredient one and 5 from ingredient two
    expect(result.getRight().toNullable(), 7);
  });

  test(
      'WHEN recipe has other recipes and ingredients '
      'SHOULD calculate it\'s cost correctly', () async {
    mockFindRecipes();
    mockFindIngredients();

    final result = await usecase.execute(2);

    // 35 from recipe and 37.5 from ingredient three
    expect(result.getRight().toNullable(), 72.5);
  });
}

const recipeWithRecipeAndIngredients = Recipe(
  id: 2,
  name: 'Complex recipe',
  quantityProduced: 10,
  canBeSold: false,
  measurementUnit: MeasurementUnit.units,
  ingredients: [
    RecipeIngredient.recipe(1, quantity: 5),
    RecipeIngredient.ingredient(3, quantity: 1.5),
  ],
);

const recipeWithIngredients = Recipe(
  id: 1,
  name: 'Recipe With Ingredients',
  quantityProduced: 1,
  canBeSold: false,
  measurementUnit: MeasurementUnit.units,
  ingredients: [
    RecipeIngredient.ingredient(1, quantity: 100),
    RecipeIngredient.ingredient(2, quantity: 200),
  ],
);

const ingredientOne = Ingredient(
  id: 1,
  name: 'Ingredient One',
  measurementUnit: MeasurementUnit.grams,
  quantity: 500,
  cost: 10,
);

const ingredientTwo = Ingredient(
  id: 2,
  name: 'Ingredient Two',
  measurementUnit: MeasurementUnit.milliliters,
  quantity: 2000,
  cost: 50,
);

const ingredientThree = Ingredient(
  id: 3,
  name: 'Ingredient Three',
  measurementUnit: MeasurementUnit.kilograms,
  quantity: 1,
  cost: 25,
);
