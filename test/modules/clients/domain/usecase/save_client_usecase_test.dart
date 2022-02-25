import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/modules/clients/domain/repository/client_repository.dart';
import 'package:kitchen_helper/modules/clients/domain/usecase/save_client_usecase.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../../mocks.dart';

void main() {
  late ClientRepository repository;
  late SaveClientUseCase usecase;

  setUp(() {
    repository = ClientRepositoryMock();
    usecase = SaveClientUseCase(repository);
  });

  test('WHEN repository returns id SHOULD return Client with new id', () async {
    when(() => repository.save(batmanClient))
        .thenAnswer((_) async => const Right(2));

    final result = await usecase.execute(batmanClient);

    expect(result.getRight().toNullable(), batmanClient.copyWith(id: 2));
  });

  test('WHEN repository returns Failure SHOULD return Failure', () async {
    final failure = FakeFailure('save failure');
    when(() => repository.save(batmanClient))
        .thenAnswer((_) async => Left(failure));

    final result = await usecase.execute(batmanClient);

    expect(result.getLeft().toNullable(), failure);
  });
}
