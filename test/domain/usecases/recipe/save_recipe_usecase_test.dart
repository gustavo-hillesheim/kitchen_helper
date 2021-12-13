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

  setUp(() {
    ingredientRepository = IngredientRepositoryMock();
    recipeRepository = RecipeRepositoryMock();
    usecase = SaveRecipeUseCase(ingredientRepository, recipeRepository);
  });

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
      mockIngredientRepositoryExists(const Right(false));

      final result = await usecase.execute(sugarWithEggRecipe);

      expect(result.isLeft(), true);
      expect(result.getLeft().toNullable()!.message,
          SaveRecipeUseCase.allIngredientsMustExistMessage);

      verify(() => ingredientRepository.exists(any()));
    },
  );

  test(
      'WHEN recipe have ingredients of type ingredient and recipe '
      'SHOULD check both repositories', () async {
    mockIngredientRepositoryExists(const Right(true));
    mockRecipeRepositoryExists(const Right(true));

    final result = await usecase.execute(cakeRecipe);

    expect(result.isRight(), true);
    verify(() => ingredientRepository.exists(any()));
    verify(() => recipeRepository.exists(any()));
  });
}
