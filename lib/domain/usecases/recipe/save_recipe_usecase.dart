import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/domain/domain.dart';

import '../../../core/core.dart';
import '../../models/models.dart';

class SaveRecipeUseCase extends UseCase<Recipe, Recipe> {
  static const allIngredientsMustExistMessage = "É necessário salvar os "
      "ingredientes antes da receita";

  final IngredientRepository ingredientRepository;
  final RecipeRepository recipeRepository;
  final RecipeIngredientRepository recipeIngredientRepository;

  SaveRecipeUseCase(
    this.ingredientRepository,
    this.recipeRepository,
    this.recipeIngredientRepository,
  );

  @override
  Future<Either<Failure, Recipe>> execute(Recipe recipe) async {
    return _validateIngredients(recipe.ingredients)
        .onRightThen((_) => recipeRepository.save(recipe))
        .onRightThen((id) => Right(recipe.copyWith(id: id)))
        .onRightThen((newRecipe) async {
      final saveIngredientsResult = await _saveIngredients(newRecipe);
      if (saveIngredientsResult.isLeft()) {
        return Left((saveIngredientsResult as Left).value);
      }
      return Right(newRecipe);
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
      final idResult =
          await recipeIngredientRepository.findId(recipe, ingredient);
      if (idResult.isLeft()) {
        return idResult;
      }
      final ingredientEntity = RecipeIngredientEntity.fromModels(
        recipe,
        ingredient,
        id: idResult.getOrElse((_) => null),
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
