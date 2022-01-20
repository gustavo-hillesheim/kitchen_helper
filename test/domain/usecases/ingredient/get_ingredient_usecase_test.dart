import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/domain/domain.dart';

import '../../../mocks.dart';
import '../crud_usecase_tests.dart';

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
