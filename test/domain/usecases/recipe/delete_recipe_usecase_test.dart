import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/domain/domain.dart';

import '../../../mocks.dart';
import '../crud_usecase_tests.dart';

void main() {
  late DeleteRecipeUseCase usecase;
  late RecipeRepository repository;

  setUp(() {
    repository = RecipeRepositoryMock();
    usecase = DeleteRecipeUseCase(repository);
  });

  deleteUseCaseTests(
    usecaseFn: () => usecase,
    repositoryFn: () => repository,
    entityWithId: sugarWithEggRecipeWithId,
    entityWithoutId: sugarWithEggRecipeWithoutId,
    errorMessageWithoutId: DeleteRecipeUseCase.cantDeleteRecipeWithoutIdMessage,
  );
}
