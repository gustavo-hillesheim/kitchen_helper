import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/core/core.dart';
import 'package:kitchen_helper/data/repository/sqlite_recipe_ingredient_repository.dart';
import 'package:kitchen_helper/domain/domain.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks.dart';

void main() {
  late SQLiteRecipeIngredientRepository repository;
  late SQLiteDatabase database;

  setUp(() {
    database = SQLiteDatabaseMock();
    repository = SQLiteRecipeIngredientRepository(database);
  });

  When<Future<List<Map<String, dynamic>>>> whenDatabaseQuery() {
    return when(
      () => database.query(
          table: any(named: 'table'),
          columns: any(named: 'columns'),
          where: any(named: 'where')),
    );
  }

  When<Future<void>> whenDatabaseDelete() {
    return when(() => database.delete(
        table: any(named: 'table'), where: any(named: 'where')));
  }

  List<RecipeIngredientEntity> getIngredientEntities(Recipe recipe) {
    return recipe.ingredients
        .map((i) => RecipeIngredientEntity.fromModels(recipe, i))
        .toList(growable: false);
  }

  group('findId', () {
    test('WHEN called SHOULD query id from database', () async {
      whenDatabaseQuery().thenAnswer((_) async => [
            {repository.idColumn: 1}
          ]);
      final ingredient = cakeRecipe.ingredients[0];

      final result = await repository.findId(cakeRecipe.id!, ingredient);

      expect(result.getRight().toNullable(), 1);
      verify(
        () => database.query(
          table: repository.tableName,
          columns: [repository.idColumn],
          where: {
            'parentRecipeId': cakeRecipe.id!,
            'recipeIngredientId': ingredient.id,
            'type': ingredient.type.getName(),
          },
        ),
      );
    });

    test('WHEN nothing is found SHOULD return null', () async {
      whenDatabaseQuery().thenAnswer((_) async => <Map<String, dynamic>>[]);

      final result =
          await repository.findId(cakeRecipe.id!, cakeRecipe.ingredients[0]);

      expect(result.getRight().toNullable(), isNull);
    });

    test('WHEN multiple values are found SHOULD return first', () async {
      whenDatabaseQuery().thenAnswer((_) async => [
            {repository.idColumn: 3},
            {repository.idColumn: 2},
            {repository.idColumn: 1},
          ]);

      final result =
          await repository.findId(cakeRecipe.id!, cakeRecipe.ingredients[0]);

      expect(result.getRight().toNullable(), 3);
    });

    test(
        'WHEN database throws DatabaseException '
        'SHOULD return Failure', () async {
      final exception = FakeDatabaseException('query error');
      whenDatabaseQuery().thenThrow(exception);

      final result =
          await repository.findId(cakeRecipe.id!, cakeRecipe.ingredients[0]);

      expect(
        result.getLeft().toNullable(),
        DatabaseFailure(SQLiteRepository.couldNotQueryMessage, exception),
      );
    });

    test(
        'WHEN database throws unknown Exception '
        'SHOULD throw Exception', () async {
      final exception = Exception('some error');
      whenDatabaseQuery().thenThrow(exception);

      try {
        await repository.findId(cakeRecipe.id!, cakeRecipe.ingredients[0]);
        fail('Should have thrown Exception');
      } catch (e) {
        expect(e, exception);
      }
    });
  });

  group('deleteByRecipe', () {
    test('WHEN called SHOULD delete all ingredients of the recipe', () async {
      whenDatabaseDelete().thenAnswer((_) async {});

      final result = await repository.deleteByRecipe(cakeRecipe.id!);

      expect(result.isRight(), true);
      verify(() => database.delete(table: repository.tableName, where: {
            'parentRecipeId': cakeRecipe.id!,
          }));
    });

    test(
        'WHEN database throws DatabaseException '
        'SHOULD return Failure', () async {
      final exception = FakeDatabaseException('test error');
      whenDatabaseDelete().thenThrow(exception);

      final result = await repository.deleteByRecipe(cakeRecipe.id!);

      expect(
        result.getLeft().toNullable(),
        DatabaseFailure(SQLiteRepository.couldNotDeleteMessage, exception),
      );
      verify(() => database.delete(table: repository.tableName, where: {
            'parentRecipeId': cakeRecipe.id!,
          }));
    });

    test(
        'WHEN database throws unknown Exception '
        'SHOULD throw Exception', () async {
      final exception = Exception('test error');
      whenDatabaseDelete().thenThrow(exception);

      try {
        await repository.deleteByRecipe(cakeRecipe.id!);
        fail('Should have thrown exception');
      } catch (e) {
        expect(e, exception);
      }

      verify(() => database.delete(table: repository.tableName, where: {
            'parentRecipeId': cakeRecipe.id!,
          }));
    });
  });

  group('findByRecipe', () {
    test('WHEN called SHOULD return the ingredients of the recipe', () async {
      whenDatabaseQuery().thenAnswer(
        (_) async =>
            getIngredientEntities(cakeRecipe).map((e) => e.toJson()).toList(),
      );

      final result = await repository.findByRecipe(cakeRecipe.id!);

      expect(result.getRight().toNullable(), getIngredientEntities(cakeRecipe));
      verify(() => database.query(
            table: repository.tableName,
            columns: [
              'id',
              'parentRecipeId',
              'recipeIngredientId',
              'type',
              'quantity',
            ],
            where: {'parentRecipeId': cakeRecipe.id!},
          ));
    });

    test(
        'WHEN database throws DatabaseException '
        'SHOULD return Failure', () async {
      final exception = FakeDatabaseException('test error');
      whenDatabaseQuery().thenThrow(exception);

      final result = await repository.findByRecipe(cakeRecipe.id!);

      expect(
        result.getLeft().toNullable(),
        DatabaseFailure(SQLiteRepository.couldNotFindAllMessage, exception),
      );
      verify(() => database.query(
            table: repository.tableName,
            columns: [
              'id',
              'parentRecipeId',
              'recipeIngredientId',
              'type',
              'quantity',
            ],
            where: {'parentRecipeId': cakeRecipe.id!},
          ));
    });

    test(
        'WHEN database throws unknown Exception '
        'SHOULD throw Exception', () async {
      final exception = Exception('test error');
      whenDatabaseQuery().thenThrow(exception);

      try {
        await repository.findByRecipe(cakeRecipe.id!);
        fail('Should have thrown exception');
      } catch (e) {
        expect(e, exception);
      }

      verify(() => database.query(
            table: repository.tableName,
            columns: [
              'id',
              'parentRecipeId',
              'recipeIngredientId',
              'type',
              'quantity',
            ],
            where: {'parentRecipeId': cakeRecipe.id!},
          ));
    });
  });
}
