import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/core/core.dart';
import 'package:kitchen_helper/modules/clients/clients.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../../mocks.dart';

void main() {
  late ContactRepository repository;
  late GetContactsDomainUseCase usecase;

  setUp(() {
    repository = ContactRepositoryMock();
    usecase = GetContactsDomainUseCase(repository);
  });

  When<Future<Either<Failure, List<ContactDomainDto>>>> mockRepository(
      int clientId) {
    return when(() => repository.findAllDomain(clientId));
  }

  test('WHEN repository returns dtos SHOULD return dtos', () async {
    const dtos = [
      ContactDomainDto(id: 1, label: 'contact@gmail.com'),
      ContactDomainDto(id: 2, label: '1234-5678'),
    ];
    mockRepository(1).thenAnswer((_) async => const Right(dtos));

    final result = await usecase.execute(1);

    expect(result.getRight().toNullable(), dtos);
  });

  test('WHEN repository returns Failure SHOULD return Failure', () async {
    const failure = FakeFailure('repository failure');
    mockRepository(1).thenAnswer((_) async => const Left(failure));

    final result = await usecase.execute(1);

    expect(result.getLeft().toNullable(), failure);
  });
}
