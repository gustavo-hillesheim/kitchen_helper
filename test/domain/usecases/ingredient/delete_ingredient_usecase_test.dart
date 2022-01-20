import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/domain/domain.dart';

import '../../../mocks.dart';
import '../crud_usecase_tests.dart';

void main() {
  late DeleteIngredientUseCase usecase;
  late IngredientRepository repository;

  setUp(() {
    repository = IngredientRepositoryMock();
    usecase = DeleteIngredientUseCase(repository);
  });

  deleteUseCaseTests(
    usecaseFn: () => usecase,
    repositoryFn: () => repository,
    entityWithId: sugarWithId,
    entityWithoutId: sugarWithoutId,
    errorMessageWithoutId:
        DeleteIngredientUseCase.cantDeleteIngredientWithoutIdMessage,
  );
}
