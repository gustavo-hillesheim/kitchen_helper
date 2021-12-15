import 'package:fpdart/fpdart.dart';

import '../../core/core.dart';
import '../../domain/domain.dart';

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
  Future<Either<Failure, List<Recipe>>> findAll() {
    return super.findAll().onRightThen(
          (recipes) => recipes
              .asyncMap((recipe) => _withIngredients(recipe))
              .then((recipes) => recipes.asEitherList()),
        );
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
}
