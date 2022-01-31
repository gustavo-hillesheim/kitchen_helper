import 'package:kitchen_helper/database/sqlite/sqlite.dart';
import 'package:kitchen_helper/modules/clients/data/repository/sqlite_address_repository.dart';
import 'package:kitchen_helper/modules/clients/data/repository/sqlite_contact_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../../mocks.dart';

void main() {
  late SQLiteDatabase database;
  late SQLiteAddressRepository repository;

  setUp(() {
    database = SQLiteDatabaseMock();
    repository = SQLiteAddressRepository(database);
  });

  group('findByClient', () {
    When<Future<List<Map<String, dynamic>>>> mockQuery(
        {required int clientId}) {
      return when(() => database.query(
            table: repository.tableName,
            columns: [
              'id',
              'clientId',
              'cep',
              'street',
              'number',
              'complement',
              'neighborhood',
              'city',
              'state',
            ],
            where: {'clientId': clientId},
          ));
    }

    test('WHEN database has records SHOULD return entities', () async {
      mockQuery(clientId: 1).thenAnswer((_) async => [
            {
              'id': 1,
              'clientId': 1,
              'cep': 12345678,
              'street': 'Test street',
              'number': 1,
              'complement': 'House',
              'neighborhood': 'Test neighborhood',
              'city': 'Test city',
              'state': 'TS',
            },
          ]);

      final result = await repository.findByClient(1);

      expect(result.getRight().toNullable(), const [
        AddressEntity(
          id: 1,
          clientId: 1,
          cep: 12345678,
          street: 'Test street',
          number: 1,
          complement: 'House',
          neighborhood: 'Test neighborhood',
          city: 'Test city',
          state: 'TS',
        ),
      ]);
    });

    test('WHEN database throws DatabaseException SHOULD return Failure',
        () async {
      mockQuery(clientId: 1).thenThrow(FakeDatabaseException('query error'));

      final result = await repository.findByClient(1);

      expect(
        result.getLeft().toNullable()?.message,
        SQLiteRepository.couldNotFindAllMessage,
      );
    });

    test('WHEN database throws unknown Exception SHOULD throw Exception',
        () async {
      final exception = Exception('query error');
      mockQuery(clientId: 1).thenThrow(exception);

      try {
        await repository.findByClient(1);
        fail('Should have thrown Exception');
      } catch (e) {
        expect(e, exception);
      }
    });
  });

  group('deleteByClient', () {
    When<Future<void>> mockDelete({required int clientId}) {
      return when(() => database.delete(
            table: repository.tableName,
            where: {'clientId': clientId},
          ));
    }

    test('WHEN database has success SHOULD return success', () async {
      mockDelete(clientId: 1).thenAnswer((_) async {});

      final result = await repository.deleteByClient(1);

      expect(result.isRight(), true);
    });

    test('WHEN database throws DatabaseException SHOULD return Failure',
        () async {
      mockDelete(clientId: 1).thenThrow(FakeDatabaseException('query error'));

      final result = await repository.deleteByClient(1);

      expect(
        result.getLeft().toNullable()?.message,
        SQLiteRepository.couldNotDeleteMessage,
      );
    });

    test('WHEN database throws unknown Exception SHOULD throw Exception',
        () async {
      final exception = Exception('query error');
      mockDelete(clientId: 1).thenThrow(exception);

      try {
        await repository.deleteByClient(1);
        fail('Should have thrown Exception');
      } catch (e) {
        expect(e, exception);
      }
    });
  });
}
