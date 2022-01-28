import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/domain/domain.dart';
import 'package:mocktail/mocktail.dart';

import '../../../mocks.dart';

void main() {
  late DeleteOrderUseCase usecase;
  late OrderRepository repository;

  setUp(() {
    repository = OrderRepositoryMock();
    usecase = DeleteOrderUseCase(repository);
  });

  test('WHEN called SHOULD delete the ingredient', () async {
    when(() => repository.deleteById(any()))
        .thenAnswer((_) async => const Right(null));

    final result = await usecase.execute(batmanOrder.id!);

    expect(result.isRight(), true);
    verify(() => repository.deleteById(batmanOrder.id!));
  });

  test('WHEN ingredient returns a Failure SHOULD return a Failure too',
      () async {
    when(() => repository.deleteById(any()))
        .thenAnswer((_) async => const Left(FakeFailure('delete error')));

    final result = await usecase.execute(batmanOrder.id!);

    expect(result.getLeft().toNullable()?.message, 'delete error');
    verify(() => repository.deleteById(batmanOrder.id!));
  });
}
