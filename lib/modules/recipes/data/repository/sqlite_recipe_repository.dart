import 'package:fpdart/fpdart.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/core.dart';
import '../../../../database/sqlite/sqlite.dart';
import '../../../../extensions.dart';
import '../../recipes.dart';
import 'sqlite_recipe_ingredient_repository.dart';

class SQLiteRecipeRepository extends SQLiteRepository<Recipe>
    implements RecipeRepository {
  final RecipeIngredientRepository recipeIngredientRepository;

  SQLiteRecipeRepository(
      SQLiteDatabase database, this.recipeIngredientRepository)
      : super(
          'recipes',
          'id',
          database,
          fromMap: (map) {
            map = Map.from(map);
            map['ingredients'] = [];
            // This is necessary since SQFLite doesn't support boolean types
            map['canBeSold'] = map['canBeSold'] == 1;
            return Recipe.fromJson(map);
          },
          toMap: (recipe) {
            final map = recipe.toJson();
            map.remove('ingredients');
            map['canBeSold'] = map['canBeSold'] == true ? 1 : 0;
            return map;
          },
        );

  @override
  Future<Either<Failure, Recipe?>> findById(int id) {
    return super.findById(id).onRightThen((recipe) async {
      if (recipe != null) {
        return _withIngredients(recipe);
      }
      return Right(recipe);
    });
  }

  @override
  Future<Either<Failure, List<Recipe>>> findAll({RecipeFilter? filter}) async {
    try {
      final where = filter != null ? _filterToMap(filter) : null;
      final entities = await database.findAll(tableName, where: where);
      final recipes = entities.map(fromMap).toList(growable: false);
      return recipes
          .asyncMap((recipe) => _withIngredients(recipe))
          .then((recipes) => recipes.asEitherList());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(SQLiteRepository.couldNotFindAllMessage, e));
    }
  }

  Map<String, dynamic> _filterToMap(RecipeFilter filter) {
    final where = <String, dynamic>{};
    if (filter.canBeSold == true) {
      where['canBeSold'] = 1;
    }
    if (filter.canBeSold == false) {
      where['canBeSold'] = 0;
    }
    return where;
  }

  @override
  Future<Either<Failure, void>> deleteById(int id) {
    return database.insideTransaction(
      () => super
          .deleteById(id)
          .onRightThen((_) => recipeIngredientRepository.deleteByRecipe(id)),
    );
  }

  @override
  Future<Either<Failure, void>> update(Recipe recipe) {
    return database.insideTransaction(
      () => super
          .update(recipe)
          .onRightThen(
              (_) => recipeIngredientRepository.deleteByRecipe(recipe.id!))
          .onRightThen((_) => _createIngredients(recipe))
          .onRightThen((_) => const Right(null)),
    );
  }

  @override
  Future<Either<Failure, int>> create(Recipe recipe) {
    return database.insideTransaction(
      () => super.create(recipe).onRightThen((recipeId) {
        recipe = recipe.copyWith(id: recipeId);
        return _createIngredients(recipe).onRightThen((_) => Right(recipeId));
      }),
    );
  }

  Future<Either<Failure, List<int>>> _createIngredients(Recipe recipe) async {
    final ingredientEntities = _createIngredientEntities(recipe);
    final futures = ingredientEntities
        .map((ingredient) => recipeIngredientRepository.create(ingredient));
    final results = await Future.wait(futures);
    return results.asEitherList();
  }

  List<RecipeIngredientEntity> _createIngredientEntities(Recipe recipe) {
    return recipe.ingredients
        .map((ingredient) =>
            RecipeIngredientEntity.fromModels(recipe, ingredient))
        .toList(growable: false);
  }

  Future<Either<Failure, Recipe>> _withIngredients(Recipe recipe) async {
    return _getIngredients(recipe).onRightThen(
      (ingredients) => Right(recipe.copyWith(ingredients: ingredients)),
    );
  }

  Future<Either<Failure, List<RecipeIngredient>>> _getIngredients(
      Recipe recipe) async {
    return recipeIngredientRepository
        .findByRecipe(recipe.id!)
        .onRightThen((ingredientEntities) {
      final ingredients = ingredientEntities
          .map((e) => e.toRecipeIngredient())
          .toList(growable: false);
      return Right(ingredients);
    });
  }

  @override
  Future<Either<Failure, List<ListingRecipeDto>>> findAllListing() async {
    try {
      final records = await database.query(
        table: tableName,
        columns: [
          'id',
          'name',
          'quantityProduced',
          'quantitySold',
          'price',
          'measurementUnit'
        ],
        orderBy: 'name COLLATE NOCASE',
      );
      return Right(records.map(ListingRecipeDto.fromJson).toList());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(SQLiteRepository.couldNotFindAllMessage, e));
    }
  }

  @override
  Future<Either<Failure, List<RecipeDomainDto>>> findAllDomain(
      {RecipeFilter? filter}) async {
    try {
      final where = filter != null ? _filterToMap(filter) : null;
      final records = await database.query(
        table: tableName,
        columns: [
          'id',
          'name label',
          'measurementUnit',
        ],
        where: where,
      );
      return Right(records.map(RecipeDomainDto.fromJson).toList());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(SQLiteRepository.couldNotFindAllMessage, e));
    }
  }

  @override
  Future<Either<Failure, Set<int>>> getRecipesThatDependOn(int recipeId) async {
    try {
      final result = <int>{};
      var filter = [recipeId];
      while (true) {
        final recipes = await _getRecipesThatDependOn(filter);
        result.addAll(recipes);
        if (recipes.isEmpty) {
          break;
        }
        filter = recipes;
      }
      return Right(result);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(SQLiteRepository.couldNotQueryMessage, e));
    }
  }

  Future<List<int>> _getRecipesThatDependOn(List<int> recipesId) async {
    final result = await database.rawQuery('''
    SELECT parentRecipeId id
    FROM recipeIngredients
    WHERE recipeIngredientId IN (${recipesId.map((_) => '?').join(', ')})
    AND type = 'recipe'
    ''', recipesId);
    return result.map((data) => data['id'] as int).toList();
  }

  @override
  Future<Either<Failure, double>> getCost(int recipeId,
      {double? quantity}) async {
    try {
      final queryResult = await database.rawQuery('''
    SELECT SUM((i.cost / i.quantity) * ri.quantity) ingredientsCost,
    GROUP_CONCAT(r.id, ',') recipesUsed, recipe.quantityProduced quantityProduced
    FROM recipes recipe
    INNER JOIN recipeIngredients ri
    LEFT JOIN ingredients i ON i.id = ri.recipeIngredientId AND ri.type = 'ingredient'
    LEFT JOIN recipes r ON r.id = ri.recipeIngredientId AND ri.type = 'recipe'
    WHERE ri.parentRecipeId = ?
''', [recipeId]);
      final firstResult = queryResult.first;
      var cost = firstResult['ingredientsCost'] as double;
      final quantityProduced = firstResult['quantityProduced'] as double;
      final recipesUsed = firstResult['recipesUsed'] as String?;
      if (recipesUsed != null && recipesUsed.isNotEmpty) {
        for (final recipe in recipesUsed.split(',')) {
          final recipeCostResult = await getCost(int.parse(recipe));
          if (recipeCostResult.isLeft()) {
            return recipeCostResult.asLeftOf();
          }
          final recipeCost = recipeCostResult.getRight().toNullable()!;
          cost += recipeCost;
        }
      }
      if (quantity != null) {
        cost = (cost / quantityProduced) * quantity;
      }
      return Right(cost);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(SQLiteRepository.couldNotQueryMessage, e));
    }
  }
}
