import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/core/core.dart';
import 'package:kitchen_helper/database/sqlite/sqlite.dart';
import 'package:kitchen_helper/modules/clients/clients.dart';
import 'package:kitchen_helper/modules/clients/data/repository/sqlite_contact_repository.dart';
import 'package:kitchen_helper/modules/clients/domain/dto/contact_domain_dto.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../../mocks.dart';

void main() {
  late SQLiteDatabase database;
  late SQLiteContactRepository repository;

  setUp(() {
    database = SQLiteDatabaseMock();
    repository = SQLiteContactRepository(database);
  });

  group('findByClient', () {
    When<Future<List<Map<String, dynamic>>>> mockQuery(
        {required int clientId}) {
      return when(() => database.query(
            table: repository.tableName,
            columns: ['id', 'clientId', 'contact'],
            where: {'clientId': clientId},
          ));
    }

    test('WHEN database has records SHOULD return entities', () async {
      mockQuery(clientId: 1).thenAnswer((_) async => [
            {'id': 1, 'clientId': 1, 'contact': '(99) 99999-9999'},
            {'id': 2, 'clientId': 1, 'contact': 'batman@gmail.com'}
          ]);

      final result = await repository.findByClient(1);

      expect(result.getRight().toNullable(), const [
        ContactEntity(id: 1, clientId: 1, contact: '(99) 99999-9999'),
        ContactEntity(id: 2, clientId: 1, contact: 'batman@gmail.com'),
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
    When<Future<List<Map<String, dynamic>>>> mockDomainQuery() {
      return when(() => database.query(
          table: repository.tableName, columns: ['id', 'contact label']));
    }

    test('WHEN database has records SHOULD return dtos', () async {
      mockDomainQuery().thenAnswer((_) async => [
            {'id': 1, 'label': 'contact@gmail.com'},
            {'id': 2, 'label': '1234-5678'}
          ]);

      final result = await repository.findAllDomain();

      expect(result.getRight().toNullable(), const [
        ContactDomainDto(id: 1, label: 'contact@gmail.com'),
        ContactDomainDto(id: 2, label: '1234-5678'),
      ]);
    });

    test('WHEN database throws DatabaseException SHOULD return Failure',
        () async {
      final exception = FakeDatabaseException('query error');
      mockDomainQuery().thenThrow(exception);

      final result = await repository.findAllDomain();

      expect(
        result.getLeft().toNullable()?.message,
        SQLiteRepository.couldNotQueryMessage,
      );
    });

    test('WHEN database throws unknown Exception SHOULD throw Exception',
        () async {
      final exception = Exception('query error');
      mockDomainQuery().thenThrow(exception);

      try {
        await repository.findAllDomain();
        fail('Should have thrown exception');
      } catch (e) {
        expect(e, exception);
      }
    });
  });
}
