import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/core/core.dart';
import 'package:kitchen_helper/domain/domain.dart';
import 'package:mocktail/mocktail.dart';

import '../../../mocks.dart';

void main() {
  late SaveRecipeUseCase usecase;
  late IngredientRepository ingredientRepository;
  late RecipeRepository recipeRepository;
  late RecipeIngredientRepository recipeIngredientRepository;

  setUp(() {
    registerFallbackValue(FakeRecipeIngredientEntity());
    registerFallbackValue(FakeRecipeIngredient());
    registerFallbackValue(FakeRecipe());
    ingredientRepository = IngredientRepositoryMock();
    recipeRepository = RecipeRepositoryMock();
    recipeIngredientRepository = RecipeIngredientRepositoryMock();
    usecase = SaveRecipeUseCase(
      ingredientRepository,
      recipeRepository,
      recipeIngredientRepository,
    );
  });

  void mockRecipeIngredientRepositorySave(Either<Failure, int> result) {
    when(() => recipeIngredientRepository.save(any()))
        .thenAnswer((_) async => result);
  }

  void mockRecipeIngredientRepositoryFindId(Either<Failure, int?> result) {
    when(() => recipeIngredientRepository.findId(any(), any()))
        .thenAnswer((_) async => result);
  }

  void mockRecipeRepositorySave(Either<Failure, int> result) {
    when(() => recipeRepository.save(any())).thenAnswer((_) async => result);
  }

  void mockIngredientRepositoryExists(Either<Failure, bool> result) {
    when(() => ingredientRepository.exists(any()))
        .thenAnswer((_) async => result);
  }

  void mockRecipeRepositoryExists(Either<Failure, bool> result) {
    when(() => recipeRepository.exists(any())).thenAnswer((_) async => result);
  }

  test(
    'WHEN not all ingredients from the recipe are saved SHOULD return Failure',
    () async {
      mockRecipeIngredientRepositoryFindId(const Right(1));
      mockRecipeIngredientRepositorySave(const Right(1));
      mockRecipeRepositorySave(const Right(1));
      mockIngredientRepositoryExists(const Right(false));

      final result = await usecase.execute(sugarWithEggRecipeWithId);

      expect(result.isLeft(), true);
      expect(result.getLeft().toNullable()!.message,
          SaveRecipeUseCase.allIngredientsMustExistMessage);

      verify(() => ingredientRepository.exists(any()));
    },
  );

  test(
      'WHEN recipe have ingredients of type ingredient and recipe '
      'SHOULD check both repositories', () async {
    mockRecipeIngredientRepositoryFindId(const Right(1));
    mockRecipeIngredientRepositorySave(const Right(1));
    mockRecipeRepositorySave(const Right(1));
    mockIngredientRepositoryExists(const Right(true));
    mockRecipeRepositoryExists(const Right(true));

    final result = await usecase.execute(cakeRecipe);

    expect(result.isRight(), true);
    verify(() => ingredientRepository.exists(any()));
    verify(() => recipeRepository.exists(any()));
  });

  test('WHEN called with a valid recipe SHOULD save it', () async {
    mockRecipeIngredientRepositoryFindId(const Right(null));
    mockRecipeIngredientRepositorySave(const Right(1));
    mockRecipeRepositorySave(const Right(1));
    mockIngredientRepositoryExists(const Right(true));

    final result = await usecase.execute(sugarWithEggRecipeWithoutId);

    expect(result.isRight(), true);
    final savedRecipe = result.getRight().toNullable()!;
    expect(savedRecipe, sugarWithEggRecipeWithId);
    verify(() => recipeRepository.save(sugarWithEggRecipeWithoutId));
    for (final ingredient in sugarWithEggRecipeWithoutId.ingredients) {
      verify(() => recipeIngredientRepository.save(RecipeIngredientEntity(
            parentRecipeId: savedRecipe.id!,
            recipeIngredientId: ingredient.id,
            type: ingredient.type,
          )));
    }
  });
}
