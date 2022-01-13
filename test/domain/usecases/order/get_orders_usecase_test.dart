import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/domain/domain.dart';
import 'package:mocktail/mocktail.dart';

import '../../../mocks.dart';
import '../crud_usecase_tests.dart';

void main() {
  late GetOrdersUseCase usecase;
  late OrderRepository repository;

  setUp(() {
    repository = OrderRepositoryMock();
    usecase = GetOrdersUseCase(repository);
  });

  getAllUseCaseTests<Order, int>(
    usecaseFn: () => usecase,
    executeUseCaseFn: (usecase) => usecase.execute(OrdersFilter()),
    repositoryFn: () => repository,
    mockRepositoryFn: (repository) => when(
      () =>
          (repository as OrderRepository).findAll(filter: any(named: 'filter')),
    ),
    verifyRepositoryFn: (repository) => verify(() =>
        (repository as OrderRepository).findAll(filter: any(named: 'filter'))),
    entities: [spidermanOrder],
  );
}
