import 'package:fpdart/fpdart.dart';

import '../../../core/core.dart';
import '../../../extensions.dart';
import '../../../modules/ingredients/ingredients.dart';
import '../../domain.dart';

class GetRecipeCostUseCase extends UseCase<Recipe, double> {
  final RecipeRepository recipeRepository;
  final IngredientRepository ingredientRepository;

  GetRecipeCostUseCase(this.recipeRepository, this.ingredientRepository);

  @override
  Future<Either<Failure, double>> execute(Recipe recipe) {
    return _calculateCostOfRecipe(recipe);
  }

  Future<Either<Failure, double>> _calculateCostOfRecipe(Recipe recipe) async {
    final futures = recipe.ingredients.map(_getRecipeIngredientCost);
    final costEithers = (await Future.wait(futures)).asEitherList();
    return costEithers.map(_sumCosts);
  }

  Future<Either<Failure, double>> _getRecipeIngredientCost(
      RecipeIngredient recipeIngredient) {
    if (recipeIngredient.type == RecipeIngredientType.ingredient) {
      return ingredientRepository
          .findById(recipeIngredient.id)
          .onRightThen((ingredient) {
        final totalCost = ingredient!.cost;
        final cost =
            totalCost / ingredient.quantity * recipeIngredient.quantity;
        return Right(cost);
      });
    } else {
      return recipeRepository.findById(recipeIngredient.id).onRightThen(
          (recipe) => _calculateCostOfRecipe(recipe!).onRightThen((totalCost) {
                final cost = totalCost /
                    recipe.quantityProduced *
                    recipeIngredient.quantity;
                return Right(cost);
              }));
    }
  }

  double _sumCosts(List<double> costs) {
    var totalCost = 0.0;
    for (final cost in costs) {
      totalCost += cost;
    }
    return totalCost;
  }
}
