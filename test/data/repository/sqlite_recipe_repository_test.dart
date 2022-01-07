import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/core/core.dart';
import 'package:kitchen_helper/data/repository/sqlite_recipe_ingredient_repository.dart';
import 'package:kitchen_helper/data/repository/sqlite_recipe_repository.dart';
import 'package:kitchen_helper/database/sqlite/sqlite.dart';
import 'package:kitchen_helper/domain/domain.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks.dart';
import '../../sqlite_repository_tests.dart';

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
}

class FakeRecipeIngredientEntity extends Fake
    implements RecipeIngredientEntity {}
