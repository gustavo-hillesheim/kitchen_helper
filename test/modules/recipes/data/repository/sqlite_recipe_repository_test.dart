import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/common/common.dart';
import 'package:kitchen_helper/core/core.dart';
import 'package:kitchen_helper/database/sqlite/sqlite.dart';
import 'package:kitchen_helper/modules/recipes/data/repository/sqlite_recipe_ingredient_repository.dart';
import 'package:kitchen_helper/modules/recipes/data/repository/sqlite_recipe_repository.dart';
import 'package:kitchen_helper/modules/recipes/recipes.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../mocks.dart';
import '../../../../sqlite_repository_tests.dart';

void main() {
  late SQLiteDatabase database;
  late RecipeIngredientRepository recipeIngredientRepository;
  late SQLiteRecipeRepository repository;

  setUp(() {
    registerFallbackValue(FakeRecipeIngredientEntity());
    database = SQLiteDatabaseMock();
    recipeIngredientRepository = RecipeIngredientRepositoryMock();
    repository = SQLiteRecipeRepository(database, recipeIngredientRepository);
  });

  void mockTransaction<T>({Function()? verify}) {
    when(() => database.insideTransaction(any()))
        .thenAnswer((invocation) async {
      final action = invocation.positionalArguments[0];
      final result = await action() as T;
      if (verify != null) {
        verify();
      }
      return result;
    });
  }

  void mockFindIngredients(
      List<Either<Failure, List<RecipeIngredientEntity>>> responses) {
    var index = 0;
    when(() => recipeIngredientRepository.findByRecipe(any()))
        .thenAnswer((_) async => responses[index++]);
  }

  List<RecipeIngredientEntity> getIngredientEntities(Recipe recipe) {
    return recipe.ingredients
        .map((i) => RecipeIngredientEntity.fromModels(recipe, i))
        .toList(growable: false);
  }

  group('findById', () {
    test(
        'WHEN there is a recipe '
        'SHOULD fill ingredients using recipeIngredientRepository', () async {
      when(() => database.findById(any(), any(), any())).thenAnswer(
          (_) async => repository.toMap(cakeRecipe.copyWith(ingredients: [])));
      mockFindIngredients([Right(getIngredientEntities(cakeRecipe))]);

      final result = await repository.findById(1);

      expect(result.getRight().toNullable(), cakeRecipe);
      verify(() =>
          database.findById(repository.tableName, repository.idColumn, 1));
      verify(() => recipeIngredientRepository.findByRecipe(cakeRecipe.id!));
    });

    test(
        'WHEN there is no recipe '
        'SHOULD not call recipeIngredientRepository', () async {
      when(() => database.findById(any(), any(), any()))
          .thenAnswer((_) async => null);

      final result = await repository.findById(1);

      expect(result.getRight().toNullable(), null);
      verify(() =>
          database.findById(repository.tableName, repository.idColumn, 1));
      verifyNever(
          () => recipeIngredientRepository.findByRecipe(cakeRecipe.id!));
    });

    testExceptionsOnFindById(() => repository, () => database);
  });

  group('findAll', () {
    test('WHEN there are recipes SHOULD fill their ingredients', () async {
      when(() => database.findAll(any())).thenAnswer((_) async => [
            repository.toMap(cakeRecipe.copyWith(ingredients: [])),
            repository
                .toMap(sugarWithEggRecipeWithId.copyWith(ingredients: [])),
          ]);
      mockFindIngredients([
        Right(getIngredientEntities(cakeRecipe)),
        Right(getIngredientEntities(sugarWithEggRecipeWithId)),
      ]);

      final result = await repository.findAll();

      expect(result.getRight().toNullable(),
          [cakeRecipe, sugarWithEggRecipeWithId]);
      verify(() => database.findAll(repository.tableName));
      verify(() => recipeIngredientRepository.findByRecipe(cakeRecipe.id!));
      verify(() => recipeIngredientRepository
          .findByRecipe(sugarWithEggRecipeWithId.id!));
    });

    test('WHEN informing filter SHOULD use where clause on database', () async {
      when(() => database.findAll(any(), where: any(named: 'where')))
          .thenAnswer((_) async => []);

      await repository.findAll(
        filter: const RecipeFilter(canBeSold: true),
      );
      verify(() => database.findAll(repository.tableName, where: {
            'canBeSold': 1,
          }));

      await repository.findAll(filter: const RecipeFilter(canBeSold: false));
      verify(() => database.findAll(repository.tableName, where: {
            'canBeSold': 0,
          }));
    });

    testExceptionsOnFindAll(() => repository, () => database, 'recipes');
  });

  group('deleteById', () {
    test('WHEN a recipe is deleted SHOULD delete its ingredients', () async {
      mockTransaction<Either<Failure, void>>(verify: () {
        verify(() => database.deleteById(
            repository.tableName, repository.idColumn, cakeRecipe.id!));
        verify(() => recipeIngredientRepository.deleteByRecipe(cakeRecipe.id!));
      });
      when(() => database.deleteById(any(), any(), any()))
          .thenAnswer((_) async {});
      when(() => recipeIngredientRepository.deleteByRecipe(any()))
          .thenAnswer((_) async => const Right(null));

      await repository.deleteById(cakeRecipe.id!);

      verify(() => database.insideTransaction(any()));
    });

    test(
        'WHEN fails to delete recipe '
        'SHOULD NOT delete its ingredients', () async {
      final exception = FakeDatabaseException('error');
      mockTransaction<Either<Failure, void>>(verify: () {
        verify(() => database.deleteById(
            repository.tableName, repository.idColumn, cakeRecipe.id!));
      });
      when(() => database.deleteById(any(), any(), any())).thenThrow(exception);

      final result = await repository.deleteById(cakeRecipe.id!);

      expect(result.getLeft().toNullable(),
          DatabaseFailure(SQLiteRepository.couldNotDeleteMessage, exception));
      verify(() => database.insideTransaction(any()));
      verifyNever(() => recipeIngredientRepository.deleteByRecipe(any()));
    });

    testExceptionsOnDeleteById(
      () => repository,
      () {
        when(() => database.insideTransaction(any())).thenAnswer((invocation) {
          final action = invocation.positionalArguments[0];
          return action();
        });
        return database;
      },
      'recipes',
      'id',
    );
  });

  group('create', () {
    test('WHEN creates a recipe SHOULD create its ingredients', () async {
      mockTransaction<Either<Failure, int>>(verify: () {
        final ingredientEntities =
            getIngredientEntities(sugarWithEggRecipeWithId);
        verify(() => database.insert(repository.tableName,
            repository.toMap(sugarWithEggRecipeWithoutId)));
        verify(() => recipeIngredientRepository.create(ingredientEntities[0]));
        verify(() => recipeIngredientRepository.create(ingredientEntities[1]));
      });
      when(() => database.insert(any(), any()))
          .thenAnswer((_) async => sugarWithEggRecipeWithId.id!);
      when(() => recipeIngredientRepository.create(any()))
          .thenAnswer((_) async => const Right(1));

      final result = await repository.create(sugarWithEggRecipeWithoutId);

      expect(result.getRight().toNullable(), sugarWithEggRecipeWithId.id!);
      verify(() => database.insideTransaction(any()));
    });

    test(
        'WHEN fails to insert recipe '
        'SHOULD not insert its ingredients', () async {
      final exception = FakeDatabaseException('error on insert');
      mockTransaction<Either<Failure, int>>(verify: () {
        verify(() => database.insert(repository.tableName,
            repository.toMap(sugarWithEggRecipeWithoutId)));
      });
      when(() => database.insert(any(), any())).thenThrow(exception);

      final result = await repository.create(sugarWithEggRecipeWithoutId);

      expect(result.getLeft().toNullable(),
          DatabaseFailure(SQLiteRepository.couldNotInsertMessage, exception));
      verify(() => database.insideTransaction(any()));
      verifyNever(() => recipeIngredientRepository.create(any()));
    });

    testExceptionsOnCreate(
      () => repository,
      () {
        when(() => database.insideTransaction(any())).thenAnswer((invocation) {
          final action = invocation.positionalArguments[0];
          return action();
        });
        return database;
      },
      sugarWithEggRecipeWithoutId,
    );
  });

  group('update', () {
    test('WHEN updating a recipe SHOULD recreate its ingredients', () async {
      mockTransaction<Either<Failure, void>>(verify: () {
        final ingredientEntities = getIngredientEntities(cakeRecipe);
        verify(() => database.update(
              repository.tableName,
              repository.toMap(cakeRecipe),
              repository.idColumn,
              cakeRecipe.id!,
            ));
        verify(() => recipeIngredientRepository.deleteByRecipe(cakeRecipe.id!));
        verify(() => recipeIngredientRepository.create(ingredientEntities[0]));
        verify(() => recipeIngredientRepository.create(ingredientEntities[1]));
      });
      when(() => database.update(any(), any(), any(), any()))
          .thenAnswer((_) async => cakeRecipe.id!);
      when(() => recipeIngredientRepository.deleteByRecipe(any()))
          .thenAnswer((_) async => const Right(null));
      when(() => recipeIngredientRepository.create(any()))
          .thenAnswer((_) async => const Right(1));

      final result = await repository.update(cakeRecipe);

      expect(result.isRight(), true);
      verify(() => database.insideTransaction(any()));
    });

    test(
        'WHEN fails to update recipe '
        'SHOULD not recreate its ingredients', () async {
      final exception = FakeDatabaseException('error on update');
      mockTransaction<Either<Failure, void>>(verify: () {
        verify(() => database.update(
              repository.tableName,
              repository.toMap(cakeRecipe),
              repository.idColumn,
              cakeRecipe.id!,
            ));
      });
      when(() => database.update(any(), any(), any(), any()))
          .thenThrow(exception);

      final result = await repository.update(cakeRecipe);

      expect(result.getLeft().toNullable(),
          DatabaseFailure(SQLiteRepository.couldNotUpdateMessage, exception));
      verify(() => database.insideTransaction(any()));
      verifyNever(() => recipeIngredientRepository.deleteByRecipe(any()));
      verifyNever(() => recipeIngredientRepository.create(any()));
    });

    testExceptionsOnUpdate(
      () => repository,
      () {
        when(() => database.insideTransaction(any())).thenAnswer((invocation) {
          final action = invocation.positionalArguments[0];
          return action();
        });
        return database;
      },
      cakeRecipe,
    );
  });

  group('converters', () {
    test(
        'WHEN toMap is called '
        'SHOULD remove ingredients and convert canBeSold to integer', () {
      const recipe = Recipe(
        name: 'Cake',
        quantityProduced: 1,
        canBeSold: false,
        measurementUnit: MeasurementUnit.units,
        ingredients: [
          RecipeIngredient.recipe(1, quantity: 2),
        ],
      );

      var result = repository.toMap(recipe);

      expect(result.containsKey('ingredients'), false);
      expect(result['canBeSold'], 0);

      result = repository.toMap(recipe.copyWith(canBeSold: true));

      expect(result['canBeSold'], 1);
    });

    test(
        'WHEN fromMap is called '
        'SHOULD add empty ingredients and convert canBeSold to bool', () {
      final json = {
        'name': 'Cake',
        'quantityProduced': 1,
        'canBeSold': 0,
        'measurementUnit': 'units',
        'ingredients': [
          {'id': 1, 'quantity': 2, 'type': 'recipe'},
        ],
      };

      var result = repository.fromMap(json);

      expect(result.canBeSold, false);
      expect(result.ingredients, []);

      json['canBeSold'] = 1;
      result = repository.fromMap(json);

      expect(result.canBeSold, true);
    });
  });

  group('findAllListing', () {
    When<Future<List<Map<String, dynamic>>>> mockQuery() {
      return when(() => database.query(
            table: repository.tableName,
            columns: any(named: 'columns'),
            orderBy: any(named: 'orderBy'),
          ));
    }

    test('WHEN database has records SHOULD return DTOs', () async {
      mockQuery().thenAnswer((_) async => [
            cakeRecipe.toJson(),
            sugarWithEggRecipeWithId.toJson(),
          ]);

      final result = await repository.findAllListing();

      expect(result.isRight(), true);
      expect(result.getRight().toNullable(), [
        listingCakeRecipeDto,
        listingSugarWithEggRecipeDto,
      ]);
      verify(() => database.query(
            table: repository.tableName,
            columns: [
              'id',
              'name',
              'quantityProduced',
              'quantitySold',
              'price',
              'measurementUnit'
            ],
            orderBy: 'name COLLATE NOCASE',
          ));
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

  group('findAllDomain', () {
    test('WHEN database has records SHOULD return DTOs', () async {
      when(() => database.query(
              table: repository.tableName,
              columns: ['id', 'name label', 'measurementUnit']))
          .thenAnswer((_) async => [
                {
                  'label': 'Cake',
                  'id': 1,
                  'measurementUnit': 'units',
                }
              ]);

      final result = await repository.findAllDomain();

      expect(result.getRight().toNullable(), [
        const RecipeDomainDto(
          id: 1,
          label: 'Cake',
          measurementUnit: MeasurementUnit.units,
        ),
      ]);
    });

    test('WHEN database throws DatabaseException SHOULD return Failure',
        () async {
      when(() => database.query(
          table: repository.tableName,
          columns: ['id', 'name label', 'measurementUnit'],
          where: {'canBeSold': 1})).thenThrow(FakeDatabaseException('error'));

      final result = await repository.findAllDomain(
        filter: const RecipeFilter(canBeSold: true),
      );

      expect(
        result.getLeft().toNullable()?.message,
        SQLiteRepository.couldNotFindAllMessage,
      );
    });

    test('WHEN database throws unknown Exception SHOULD return Failure',
        () async {
      when(() => database.query(
              table: repository.tableName,
              columns: ['id', 'name label', 'measurementUnit']))
          .thenThrow(Exception('error'));

      try {
        await repository.findAllDomain();
        fail('Should have thrown Exception');
      } on Exception catch (e) {
        expect(e, isA<Exception>());
      }
    });
  });

  group('getRecipesThatDependOn', () {
    test('WHEN database has records SHOULD return ids', () async {
      final answers = <List<Map<String, dynamic>>>[
        [
          {'id': 2},
          {'id': 3}
        ],
        [
          {'id': 5}
        ],
        []
      ];
      when(() => database.rawQuery(any(), any()))
          .thenAnswer((_) async => answers.removeAt(0));

      final result = await repository.getRecipesThatDependOn(1);

      expect(result.getRight().toNullable(), {2, 3, 5});
    });

    test('WHEN database throws DatabaseException SHOULD return Failure',
        () async {
      when(() => database.rawQuery(any(), any()))
          .thenThrow(FakeDatabaseException('error'));

      final result = await repository.getRecipesThatDependOn(1);

      expect(
        result.getLeft().toNullable()?.message,
        SQLiteRepository.couldNotQueryMessage,
      );
    });

    test('WHEN database throws unknown Exception SHOULD return Failure',
        () async {
      when(() => database.rawQuery(any(), any())).thenThrow(Exception('error'));

      try {
        await repository.getRecipesThatDependOn(1);
        fail('Should have thrown Exception');
      } on Exception catch (e) {
        expect(e, isA<Exception>());
      }
    });
  });
  group('getCost', () {
    When<Future<List<Map<String, dynamic>>>> mockCostQuery(int recipeId) {
      return when(() => database.rawQuery(any(), [recipeId]));
    }

    test('WHEN recipe only have ingredients SHOULD only execute one query',
        () async {
      const recipeId = 1;
      mockCostQuery(recipeId).thenAnswer((_) async => [
            {
              'ingredientsCost': 50.0,
              'recipesUsed': null,
              'quantityProduced': 1.0
            }
          ]);

      final result = await repository.getCost(recipeId);

      expect(result.getRight().toNullable(), 50);
    });

    test(
        'WHEN recipe have ingredients and recipes SHOULD query for each child recipe',
        () async {
      const recipeId = 1;
      const childRecipeOneId = 2;
      const childRecipeTwoId = 3;
      mockCostQuery(recipeId).thenAnswer((_) async => [
            {
              'ingredientsCost': 50.0,
              'recipesUsed': '$childRecipeOneId,$childRecipeTwoId',
              'quantityProduced': 1.0
            }
          ]);
      mockCostQuery(childRecipeOneId).thenAnswer((_) async => [
            {
              'ingredientsCost': 10.0,
              'recipesUsed': null,
              'quantityProduced': 1.0
            }
          ]);
      mockCostQuery(childRecipeTwoId).thenAnswer((_) async => [
            {
              'ingredientsCost': 15.0,
              'recipesUsed': '$childRecipeOneId',
              'quantityProduced': 1.0
            }
          ]);

      final result = await repository.getCost(recipeId);

      expect(result.getRight().toNullable(), 85);
    });

    test(
        'WHEN quantity is provided SHOULD calculate cost to produce that quantity',
        () async {
      const recipeId = 1;
      const quantity = 10.0;
      mockCostQuery(recipeId).thenAnswer((_) async => [
            {
              'ingredientsCost': 50.0,
              'recipesUsed': null,
              'quantityProduced': 100.0
            }
          ]);

      final result = await repository.getCost(recipeId, quantity: quantity);

      expect(result.getRight().toNullable(), 5);
    });

    test(
        'WHEN database throws DatabaseException on first query SHOULD return Failure',
        () async {
      final exception = FakeDatabaseException('query error');
      const recipeId = 1;
      mockCostQuery(recipeId).thenThrow(exception);

      final result = await repository.getCost(recipeId);

      expect(
        result.getLeft().toNullable()?.message,
        SQLiteRepository.couldNotQueryMessage,
      );
    });

    test('WHEN database throws exception on first query SHOULD throw exception',
        () async {
      final exception = Exception('unknown error');
      const recipeId = 1;
      mockCostQuery(recipeId).thenThrow(exception);

      try {
        await repository.getCost(recipeId);
        fail('Should have thrown exception');
      } catch (e) {
        expect(e, exception);
      }
    });

    test(
        'WHEN database throws DatabaseException on nested queries SHOULD return Failure',
        () async {
      final exception = FakeDatabaseException('query error');
      const recipeId = 1;
      const childRecipeId = 2;
      mockCostQuery(recipeId).thenAnswer((_) async => [
            {
              'ingredientsCost': 50.0,
              'recipesUsed': '$childRecipeId',
              'quantityProduced': 1.0
            }
          ]);
      mockCostQuery(childRecipeId).thenThrow(exception);

      final result = await repository.getCost(recipeId);

      expect(
        result.getLeft().toNullable()?.message,
        SQLiteRepository.couldNotQueryMessage,
      );
    });

    test(
        'WHEN database throws exception on nested query SHOULD throw exception',
        () async {
      final exception = Exception('unknown error');
      const recipeId = 1;
      const childRecipeId = 2;
      mockCostQuery(recipeId).thenAnswer((_) async => [
            {
              'ingredientsCost': 50.0,
              'recipesUsed': '$childRecipeId',
              'quantityProduced': 1.0
            }
          ]);
      mockCostQuery(childRecipeId).thenThrow(exception);

      try {
        await repository.getCost(recipeId);
        fail('Should have thrown exception');
      } catch (e) {
        expect(e, exception);
      }
    });
  });
}

class FakeRecipeIngredientEntity extends Fake
    implements RecipeIngredientEntity {}
