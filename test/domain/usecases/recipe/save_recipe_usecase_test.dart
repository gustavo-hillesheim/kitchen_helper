import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/domain/repository/ingredient_repository.dart';
import 'package:kitchen_helper/domain/usecases/recipe/save_recipe_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../../mocks.dart';

void main() {
  late SaveRecipeUseCase usecase;
  late IngredientRepository ingredientRepository;

  setUp(() {
    ingredientRepository = IngredientRepositoryMock();
    usecase = SaveRecipeUseCase(ingredientRepository);
  });

  test(
    'WHEN not all ingredients from the recipe are saved SHOULD return Failure',
    () async {
      when(() => ingredientRepository.exists(any()))
          .thenAnswer((_) async => const Right(false));

      final result = await usecase.execute(sugarWithEggRecipe);

      expect(result.isLeft(), true);
    },
  );
}
