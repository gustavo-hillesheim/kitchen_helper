import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:kitchen_helper/modules/orders/domain/domain.dart';

import '../../../../mocks.dart';

void main() {
  late OrderRepository repository;
  late GetEditingOrderDtoUseCase usecase;

  setUp(() {
    repository = OrderRepositoryMock();
    usecase = GetEditingOrderDtoUseCase(repository);
  });

  test('WHNE repository returns entity SHOULD return entity', () async {
    when(() => repository.findEditingDtoById(1))
        .thenAnswer((_) async => Right(editingSpidermanOrderDtoWithId));

    final result = await usecase.execute(1);

    expect(result.getRight().toNullable(), editingSpidermanOrderDtoWithId);
  });

  test('WHNE repository returns Failure SHOULD return Failure', () async {
    const failure = FakeFailure('some failure');
    when(() => repository.findEditingDtoById(1))
        .thenAnswer((_) async => const Left(failure));

    final result = await usecase.execute(1);

    expect(result.getLeft().toNullable(), failure);
  });

  test('WHNE repository returns null SHOULD return Failure', () async {
    when(() => repository.findEditingDtoById(1))
        .thenAnswer((_) async => const Right(null));

    final result = await usecase.execute(1);

    expect(
      result.getLeft().toNullable()?.message,
      GetEditingOrderDtoUseCase.couldntFindEntityMessage,
    );
  });
}
