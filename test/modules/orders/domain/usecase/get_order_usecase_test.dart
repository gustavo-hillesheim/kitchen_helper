import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/modules/orders/orders.dart';

import '../../../../crud_usecase_tests.dart';
import '../../../../mocks.dart';

void main() {
  late GetOrderUseCase usecase;
  late OrderRepository repository;

  setUp(() {
    repository = OrderRepositoryMock();
    usecase = GetOrderUseCase(repository);
  });

  getUseCaseTests(
    usecaseFn: () => usecase,
    repositoryFn: () => repository,
    entity: spidermanOrderWithId,
    id: spidermanOrderWithId.id,
  );
}
