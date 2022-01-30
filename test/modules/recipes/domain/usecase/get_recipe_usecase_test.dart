import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/modules/recipes/recipes.dart';

import '../../../../domain/usecases/crud_usecase_tests.dart';
import '../../../../mocks.dart';

void main() {
  late GetRecipeUseCase usecase;
  late RecipeRepository repository;

  setUp(() {
    repository = RecipeRepositoryMock();
    usecase = GetRecipeUseCase(repository);
  });

  getUseCaseTests<Recipe, int>(
    usecaseFn: () => usecase,
    repositoryFn: () => repository,
    entity: cakeRecipe,
    id: cakeRecipe.id!,
  );
}
