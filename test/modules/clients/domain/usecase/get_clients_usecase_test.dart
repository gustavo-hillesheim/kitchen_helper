import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/core/core.dart';
import 'package:kitchen_helper/modules/clients/domain/repository/client_repository.dart';
import 'package:kitchen_helper/modules/clients/domain/usecase/get_clients_usecase.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../../mocks.dart';

void main() {
  late GetClientsUseCase usecase;
  late ClientRepository repository;

  setUp(() {
    repository = ClientRepositoryMock();
    usecase = GetClientsUseCase(repository);
  });

  test('WHEN repository returns DTOs SHOULD return DTOs', () async {
    when(() => repository.findAllListing())
        .thenAnswer((_) async => const Right(listingClientDtos));

    final result = await usecase.execute(const NoParams());

    expect(result.getRight().toNullable(), listingClientDtos);
  });

  test('WHEN repository returns Failure SHOULD return Failure', () async {
    final failure = FakeFailure('find failure');
    when(() => repository.findAllListing())
        .thenAnswer((_) async => Left(failure));

    final result = await usecase.execute(const NoParams());

    expect(result.getLeft().toNullable(), failure);
  });
}
