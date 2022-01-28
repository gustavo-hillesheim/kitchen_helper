import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/data/repository/sqlite_ingredient_repository.dart';
import 'package:kitchen_helper/database/sqlite/sqlite.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks.dart';

void main() {
  late SQLiteDatabase database;
  late SQLiteIngredientRepository repository;

  setUp(() {
    database = SQLiteDatabaseMock();
    repository = SQLiteIngredientRepository(database);
  });

  When<Future<List<Map<String, dynamic>>>> mockQuery() {
    return when(() => database.query(
          table: repository.tableName,
          columns: any(named: 'columns'),
          orderBy: any(named: 'orderBy'),
        ));
  }

  group('findAllListing', () {
    test('WHEN database has records SHOULD return DTOs', () async {
      mockQuery().thenAnswer((_) async => [
            egg.toJson(),
            flour.toJson(),
            orangeJuice.toJson(),
          ]);

      final result = await repository.findAllListing();

      expect(result.isRight(), true);
      expect(result.getRight().toNullable(), [
        listingEggDto,
        listingFlourDto,
        listingOrangeJuiceDto,
      ]);
    });

    test('WHEN database throws known Exception SHOULD return Failure',
        () async {
      mockQuery().thenThrow(FakeDatabaseException('database exception'));

      final result = await repository.findAllListing();

      expect(result.isLeft(), true);
      expect(
        result.getLeft().toNullable()?.message,
        SQLiteRepository.couldNotFindAllMessage,
      );
    });

    test('WHEN database throws unknown Exception SHOULD throw Exception',
        () async {
      mockQuery().thenThrow(Exception('unknown exception'));

      try {
        await repository.findAllListing();
        fail('Should have thrown Exception');
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });
  });
}
