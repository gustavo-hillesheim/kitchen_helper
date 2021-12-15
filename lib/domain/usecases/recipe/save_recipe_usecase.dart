import 'package:fpdart/fpdart.dart';

import '../../../core/core.dart';
import '../../domain.dart';

class SaveRecipeUseCase extends UseCase<Recipe, Recipe> {
  static const allIngredientsMustExistMessage = "É necessário salvar os "
      "ingredientes antes da receita";

  final SQLiteDatabase database;
  final IngredientRepository ingredientRepository;
  final RecipeRepository recipeRepository;
  final RecipeIngredientRepository recipeIngredientRepository;

  SaveRecipeUseCase(
    this.database,
    this.ingredientRepository,
    this.recipeRepository,
    this.recipeIngredientRepository,
  );

  @override
  Future<Either<Failure, Recipe>> execute(Recipe recipe) async {
    return _validateIngredients(recipe.ingredients).onRightThen(
        (_) => database.insideTransaction(() => _saveRecipe(recipe)));
  }

  Future<Either<Failure, Recipe>> _saveRecipe(Recipe recipe) {
    return recipeRepository
        .save(recipe)
        .onRightThen((id) => Right(recipe.copyWith(id: id)))
        .onRightThen((recipe) async {
      final saveIngredientsResult = await _saveIngredients(recipe);
      if (saveIngredientsResult.isLeft()) {
        return Left(saveIngredientsResult.getLeft().toNullable()!);
      }
      return Right(recipe);
    });
  }

  Future<Either<Failure, void>> _validateIngredients(
      List<RecipeIngredient> ingredients) async {
    for (final ingredient in ingredients) {
      final result = await _validateIngredient(ingredient);
      if (result.isLeft()) {
        return result;
      }
    }
    return const Right(null);
  }

  Future<Either<Failure, void>> _validateIngredient(
      RecipeIngredient ingredient) async {
    final existsResult = ingredient.type == RecipeIngredientType.ingredient
        ? await ingredientRepository.exists(ingredient.id)
        : await recipeRepository.exists(ingredient.id);
    if (existsResult.isLeft()) {
      return existsResult;
    }
    final exists = existsResult.getRight().getOrElse(() => false);
    if (!exists) {
      return const Left(BusinessFailure(allIngredientsMustExistMessage));
    }
    return const Right(null);
  }

  Future<Either<Failure, void>> _saveIngredients(Recipe recipe) async {
    for (final ingredient in recipe.ingredients) {
      /*final idResult =
          await recipeIngredientRepository.findId(recipe, ingredient);
      if (idResult.isLeft()) {
        return idResult;
      }*/
      final ingredientEntity = RecipeIngredientEntity.fromModels(
        recipe,
        ingredient,
        id: 1,
      );
      final saveResult =
          await recipeIngredientRepository.save(ingredientEntity);
      if (saveResult.isLeft()) {
        return saveResult;
      }
    }
    return const Right(null);
  }
}
