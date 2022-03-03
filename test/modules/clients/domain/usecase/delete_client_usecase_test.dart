import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/modules/clients/domain/repository/client_repository.dart';
import 'package:kitchen_helper/modules/clients/domain/usecase/delete_client_usecase.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../../mocks.dart';

void main() {
  late ClientRepository repository;
  late DeleteClientUseCase usecase;

  setUp(() {
    repository = ClientRepositoryMock();
    usecase = DeleteClientUseCase(repository);
  });

  test('WHEN repository returns sucess SHOULD return success', () async {
    when(() => repository.deleteById(1))
        .thenAnswer((_) async => const Right(null));

    final result = await usecase.execute(1);

    expect(result.isRight(), true);
  });

  test('WHEN repository returns Failure SHOULD return Failure', () async {
    final failure = FakeFailure('delete failure');
    when(() => repository.deleteById(1)).thenAnswer((_) async => Left(failure));

    final result = await usecase.execute(1);

    expect(result.getLeft().toNullable(), failure);
  });
}
