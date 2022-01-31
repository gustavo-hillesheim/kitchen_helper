import 'package:kitchen_helper/database/sqlite/sqlite.dart';
import 'package:kitchen_helper/modules/clients/data/repository/sqlite_client_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../../mocks.dart';

void main() {
  late SQLiteDatabase database;
  late SQLiteClientRepository repository;

  setUp(() {
    database = SQLiteDatabaseMock();
    repository = SQLiteClientRepository(database);
  });

  group('converters', () {
    test('SHOULD convert to map', () {
      final map = repository.toMap(batmanClient);

      expect(map.length, 2);
      expect(map['id'], batmanClient.id);
      expect(map['name'], batmanClient.name);
    });
    test('SHOULD convert from map', () {
      final client = repository.fromMap({'id': 1, 'name': 'Batman'});

      expect(client, batmanClient.copyWith(addresses: [], contacts: []));
    });
  });

  group('findAllListing', () {
    When<Future<List<Map<String, dynamic>>>> whenQuery() {
      return when(() =>
          database.query(table: repository.tableName, columns: ['id', 'name']));
    }

    test('WHEN database has records SHOULD return DTOs', () async {
      whenQuery().thenAnswer((_) async => [
            {'id': 1, 'name': 'Batman'},
            {'id': 2, 'name': 'Spider man'}
          ]);

      final result = await repository.findAllListing();

      expect(result.getRight().toNullable(), listingClientDtos);
    });

    test('WHEN database throws DatabaseException SHOULD return Failure',
        () async {
      whenQuery().thenThrow(FakeDatabaseException('database exception'));

      final result = await repository.findAllListing();

      expect(
        result.getLeft().toNullable()?.message,
        SQLiteRepository.couldNotFindAllMessage,
      );
    });

    test('WHEN database throws unknown Exception SHOULD throw Exception',
        () async {
      final exception = Exception('some error');
      whenQuery().thenThrow(exception);
      try {
        await repository.findAllListing();
        fail('Should have thrown');
      } catch (e) {
        expect(e, exception);
      }
    });
  });
}
