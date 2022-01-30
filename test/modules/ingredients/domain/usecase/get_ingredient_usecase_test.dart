import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/modules/ingredients/ingredients.dart';

import '../../../../domain/usecases/crud_usecase_tests.dart';
import '../../../../mocks.dart';

void main() {
  late GetIngredientUseCase usecase;
  late IngredientRepository repository;

  setUp(() {
    repository = IngredientRepositoryMock();
    usecase = GetIngredientUseCase(repository);
  });

  getUseCaseTests(
    usecaseFn: () => usecase,
    repositoryFn: () => repository,
    entity: sugarWithId,
    id: sugarWithId.id!,
  );
}
