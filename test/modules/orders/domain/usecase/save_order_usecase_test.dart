import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/modules/orders/orders.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../crud_usecase_tests.dart';
import '../../../../mocks.dart';

void main() {
  late SaveOrderUseCase usecase;
  late OrderRepository repository;

  setUp(() {
    registerFallbackValue(FakeOrder());
    repository = OrderRepositoryMock();
    usecase = SaveOrderUseCase(repository);
  });

  saveUseCaseTests(
    usecaseFn: () => usecase,
    repositoryFn: () => repository,
    entityWithId: spidermanOrderWithId,
    entityWithoutId: spidermanOrder,
    id: spidermanOrderWithId.id!,
  );
}
