import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/core/core.dart';
import 'package:kitchen_helper/modules/clients/clients.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../../mocks.dart';

void main() {
  late GetClientsDomainUseCase usecase;
  late ClientRepository repository;

  setUp(() {
    repository = ClientRepositoryMock();
    usecase = GetClientsDomainUseCase(repository);
  });

  When<Future<Either<Failure, List<ClientDomainDto>>>> mockQuery() {
    return when(() => repository.findAllDomain());
  }

  test('WHEN repository has records SHOULD return dtos', () async {
    mockQuery().thenAnswer((_) async => const Right(dtos));

    final result = await usecase.execute(const NoParams());

    expect(result.getRight().toNullable(), dtos);
  });

  test('WHEN repository return Failure SHOULD return Failure', () async {
    final failure = FakeFailure('error on query');
    mockQuery().thenAnswer((_) async => Left(failure));

    final result = await usecase.execute(const NoParams());

    expect(result.getLeft().toNullable(), failure);
  });
}

const dtos = [
  ClientDomainDto(id: 1, label: 'Client one'),
  ClientDomainDto(id: 2, label: 'Client two'),
  ClientDomainDto(id: 3, label: 'Client three'),
];
