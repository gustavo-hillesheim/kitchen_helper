import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/domain/domain.dart';

import '../../../mocks.dart';
import '../crud_usecase_tests.dart';

void main() {
  late GetIngredientsUseCase usecase;
  late IngredientRepository repository;

  setUp(() {
    repository = IngredientRepositoryMock();
    usecase = GetIngredientsUseCase(repository);
  });

  getAllUseCaseTests(
    usecaseFn: () => usecase,
    repositoryFn: () => repository,
    entities: ingredientList,
  );
}
