import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/domain/domain.dart';

import '../../../mocks.dart';
import '../crud_usecase_tests.dart';

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
    entity: cakeOrderWithId,
    id: cakeOrderWithId.id,
  );
}
