import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/modules/orders/orders.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../mocks.dart';

void main() {
  late GetOrdersUseCase usecase;
  late OrderRepository repository;

  setUp(() {
    repository = OrderRepositoryMock();
    usecase = GetOrdersUseCase(repository);
  });

  test('WHEN called SHOULD get entities', () async {
    when(() => repository.findAllListing(filter: any(named: 'filter')))
        .thenAnswer((_) async => Right([listingBatmanOrderDto]));

    final result = await usecase.execute(const OrdersFilter());

    expect(result.getRight().toNullable(), [listingBatmanOrderDto]);
    verify(() => repository.findAllListing(filter: const OrdersFilter()));
  });

  test('WHEN repository returns Failure SHOULD return Failure', () async {
    when(() => repository.findAllListing(filter: any(named: 'filter')))
        .thenAnswer((_) async => Left(FakeFailure('error')));

    final result = await usecase.execute(const OrdersFilter());

    expect(result.getLeft().toNullable()?.message, 'error');
    verify(() => repository.findAllListing(filter: const OrdersFilter()));
  });
}
