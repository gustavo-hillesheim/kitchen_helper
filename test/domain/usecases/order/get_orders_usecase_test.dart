import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/domain/domain.dart';

import '../../../mocks.dart';
import '../crud_usecase_tests.dart';

void main() {
  late GetOrdersUseCase usecase;
  late OrderRepository repository;

  setUp(() {
    repository = OrderRepositoryMock();
    usecase = GetOrdersUseCase(repository);
  });

  getAllUseCaseTests(
    usecaseFn: () => usecase,
    repositoryFn: () => repository,
    entities: [spidermanOrder],
  );
}
