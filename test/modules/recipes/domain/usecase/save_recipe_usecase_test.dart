import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/modules/recipes/recipes.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../crud_usecase_tests.dart';
import '../../../../mocks.dart';

void main() {
  late SaveRecipeUseCase usecase;
  late RecipeRepository repository;

  setUp(() {
    registerFallbackValue(FakeRecipe());
    repository = RecipeRepositoryMock();
    usecase = SaveRecipeUseCase(repository);
  });

  saveUseCaseTests(
    usecaseFn: () => usecase,
    repositoryFn: () => repository,
    entityWithId: cakeRecipe,
    entityWithoutId: cakeRecipeWithoutId,
    id: 5,
  );
}
