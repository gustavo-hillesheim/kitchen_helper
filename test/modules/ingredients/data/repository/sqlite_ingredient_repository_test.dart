import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/common/common.dart';
import 'package:kitchen_helper/core/core.dart';
import 'package:kitchen_helper/database/sqlite/query_operators.dart';
import 'package:kitchen_helper/database/sqlite/sqlite.dart';
import 'package:kitchen_helper/modules/ingredients/data/repository/sqlite_ingredient_repository.dart';
import 'package:kitchen_helper/modules/ingredients/domain/domain.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../../mocks.dart';

void main() {
  late SQLiteDatabase database;
  late SQLiteIngredientRepository repository;

  setUp(() {
    database = SQLiteDatabaseMock();
    repository = SQLiteIngredientRepository(database);
  });

  group('findAllListing', () {
    Future<List<Map<String, dynamic>>> findAllListingQuery(
        {Map<String, dynamic>? where}) {
      return database.query(
        table: repository.tableName,
        columns: ['id', 'name', 'measurementUnit', 'quantity', 'cost'],
        orderBy: 'name COLLATE NOCASE',
        where: where,
      );
    }

    test('WHEN filter is not provided SHOULD execute default query', () async {
      when(findAllListingQuery).thenAnswer((_) async => []);

      await repository.findAllListing();

      verify(findAllListingQuery);
    });

    test('WHEN filter is provided SHOULD execute query using filter', () async {
      const whereClause = {'name': Contains('Egg')};
      when(() => findAllListingQuery(where: whereClause))
          .thenAnswer((_) async => []);

      await repository.findAllListing(
        filter: const IngredientsFilter(name: 'Egg'),
      );

      verify(() => findAllListingQuery(where: whereClause));
    });
  });
}
