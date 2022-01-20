import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/domain/domain.dart';
import 'package:kitchen_helper/domain/usecases/order/save_order_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../../mocks.dart';
import '../crud_usecase_tests.dart';

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
