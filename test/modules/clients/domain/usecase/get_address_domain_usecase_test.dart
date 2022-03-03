import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/core/core.dart';
import 'package:kitchen_helper/modules/clients/clients.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../../mocks.dart';

void main() {
  late GetAddressDomainUseCase usecase;
  late AddressRepository repository;

  setUp(() {
    repository = AddressRepositoryMock();
    usecase = GetAddressDomainUseCase(repository);
  });

  When<Future<Either<Failure, List<AddressDomainDto>>>> mockDomainQuery(
      int clientId) {
    return when(() => repository.findAllDomain(clientId));
  }

  test('WHEN repository returns dtos SHOULD return dtos', () async {
    const dtos = [
      AddressDomainDto(id: 1, label: 'Address one'),
      AddressDomainDto(id: 2, label: 'Address two'),
    ];
    mockDomainQuery(1).thenAnswer((_) async => const Right(dtos));

    final result = await usecase.execute(1);

    expect(result.getRight().toNullable(), dtos);
  });

  test('WHEN repository returns Failure SHOULD return Failure', () async {
    final failure = FakeFailure('query failure');
    mockDomainQuery(1).thenAnswer((_) async => Left(failure));

    final result = await usecase.execute(1);

    expect(result.getLeft().toNullable(), failure);
  });
}
