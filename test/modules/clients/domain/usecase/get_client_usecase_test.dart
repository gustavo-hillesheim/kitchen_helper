import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/modules/clients/domain/model/address.dart';
import 'package:kitchen_helper/modules/clients/domain/model/client.dart';
import 'package:kitchen_helper/modules/clients/domain/model/contact.dart';
import 'package:kitchen_helper/modules/clients/domain/repository/client_repository.dart';
import 'package:kitchen_helper/modules/clients/domain/usecase/get_client_usecase.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../../mocks.dart';

void main() {
  late ClientRepository repository;
  late GetClientUseCase usecase;

  setUp(() {
    repository = ClientRepositoryMock();
    usecase = GetClientUseCase(repository);
  });

  test('WHEN repository returns Client SHOULD return Client', () async {
    when(() => repository.findById(1))
        .thenAnswer((_) async => const Right(batmanClient));

    final result = await usecase.execute(1);

    expect(result.getRight().toNullable(), batmanClient);
  });

  test('WHEN repository returns Failure SHOULD return Failure', () async {
    const failure = FakeFailure('get failure');
    when(() => repository.findById(2))
        .thenAnswer((_) async => const Left(failure));

    final result = await usecase.execute(2);

    expect(result.getLeft().toNullable(), failure);
  });
}
