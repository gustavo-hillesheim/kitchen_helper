import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/domain/domain.dart';
import 'package:mocktail/mocktail.dart';

import '../../../mocks.dart';
import '../crud_usecase_tests.dart';

void main() {
  late GetRecipesUseCase usecase;
  late RecipeRepository repository;

  setUp(() {
    repository = RecipeRepositoryMock();
    usecase = GetRecipesUseCase(repository);
  });

  getAllUseCaseTests<Recipe, int>(
    usecaseFn: () => usecase,
    executeUseCaseFn: (usecase) => usecase.execute(const RecipeFilter()),
    repositoryFn: () => repository,
    mockRepositoryFn: (repository) => when(
      () => (repository as RecipeRepository)
          .findAll(filter: any(named: 'filter')),
    ),
    verifyRepositoryFn: (repository) => verify(
      () => (repository as RecipeRepository)
          .findAll(filter: any(named: 'filter')),
    ),
    entities: [cakeRecipe, sugarWithEggRecipeWithId],
  );
}
