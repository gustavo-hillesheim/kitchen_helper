import 'package:kitchen_helper/database/sqlite/sqlite.dart';
import 'package:kitchen_helper/modules/clients/clients.dart';
import 'package:kitchen_helper/modules/clients/data/repository/sqlite_address_repository.dart';
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
              'identifier',
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
              'identifier': 'Test street, 1',
              'cep': 12345678,
              'street': 'Test street',
              'number': 1,
              'complement': 'House',
              'neighborhood': 'Test neighborhood',
              'city': 'Test city',
              'state': 'SP',
            },
          ]);

      final result = await repository.findByClient(1);

      expect(result.getRight().toNullable(), const [
        AddressEntity(
          id: 1,
          clientId: 1,
          identifier: 'Test street, 1',
          cep: 12345678,
          street: 'Test street',
          number: 1,
          complement: 'House',
          neighborhood: 'Test neighborhood',
          city: 'Test city',
          state: States.SP,
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

  group('findAllDomain', () {
    When<Future<List<Map<String, dynamic>>>> mockDomainQuery(int clientId) {
      return when(() => database.query(
            table: repository.tableName,
            columns: ['id', 'identifier label'],
            where: {'clientId': clientId},
          ));
    }

    test('WHEN database has records SHOULD return dtos', () async {
      mockDomainQuery(1).thenAnswer((_) async => [
            {'id': 1, 'label': 'my address'},
            {'id': 2, 'label': 'some other address'}
          ]);

      final result = await repository.findAllDomain(1);

      expect(result.getRight().toNullable(), const [
        AddressDomainDto(id: 1, label: 'my address'),
        AddressDomainDto(id: 2, label: 'some other address'),
      ]);
    });

    test('WHEN database throws DatabaseException SHOULD return Failure',
        () async {
      final exception = FakeDatabaseException('query error');
      mockDomainQuery(1).thenThrow(exception);

      final result = await repository.findAllDomain(1);

      expect(
        result.getLeft().toNullable()?.message,
        SQLiteRepository.couldNotQueryMessage,
      );
    });

    test('WHEN database throws unknown Exception SHOULD throw Exception',
        () async {
      final exception = Exception('query error');
      mockDomainQuery(1).thenThrow(exception);

      try {
        await repository.findAllDomain(1);
        fail('Should have thrown exception');
      } catch (e) {
        expect(e, exception);
      }
    });
  });
}
