import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/domain/domain.dart';
import 'package:mocktail/mocktail.dart';

import '../../../mocks.dart';
import '../crud_usecase_tests.dart';

void main() {
  late SaveIngredientUseCase usecase;
  late IngredientRepository repository;

  setUp(() {
    registerFallbackValue(FakeIngredient());
    repository = IngredientRepositoryMock();
    usecase = SaveIngredientUseCase(repository);
  });

  saveUseCaseTests(
    usecaseFn: () => usecase,
    repositoryFn: () => repository,
    entityWithId: sugarWithId,
    entityWithoutId: sugarWithoutId,
    id: sugarWithId.id!,
  );
}
