import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/domain/domain.dart';

import '../../../mocks.dart';
import '../crud_usecase_tests.dart';

void main() {
  late GetRecipesUseCase usecase;
  late RecipeRepository repository;

  setUp(() {
    repository = RecipeRepositoryMock();
    usecase = GetRecipesUseCase(repository);
  });

  getAllUseCaseTests(
    usecaseFn: () => usecase,
    repositoryFn: () => repository,
    entities: [cakeRecipe, sugarWithEggRecipeWithId],
  );
}
