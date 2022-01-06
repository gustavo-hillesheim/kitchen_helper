import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/domain/domain.dart';

import '../../../mocks.dart';
import '../crud_usecase_tests.dart';

void main() {
  late DeleteOrderUseCase usecase;
  late OrderRepository repository;

  setUp(() {
    repository = OrderRepositoryMock();
    usecase = DeleteOrderUseCase(repository);
  });

  deleteUseCaseTests(
    usecaseFn: () => usecase,
    repositoryFn: () => repository,
    entityWithId: cakeOrderWithId,
    entityWithoutId: cakeOrder,
    errorMessageWithoutId: DeleteOrderUseCase.cantDeleteOrderWithoutIdMessage,
  );
}
