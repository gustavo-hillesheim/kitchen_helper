import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/domain/domain.dart';

import '../../../mocks.dart';
import '../crud_usecase_tests.dart';

void main() {
  late GetRecipeUseCase usecase;
  late RecipeRepository repository;

  setUp(() {
    repository = RecipeRepositoryMock();
    usecase = GetRecipeUseCase(repository);
  });

  getUseCaseTests(
    usecaseFn: () => usecase,
    repositoryFn: () => repository,
    entity: cakeRecipe,
    id: cakeRecipe.id!,
  );
}
