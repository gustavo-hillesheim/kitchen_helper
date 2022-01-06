import 'package:fpdart/fpdart.dart';

import '../../../core/core.dart';
import '../../../domain/domain.dart';
import '../../../extensions.dart';
import '../states.dart';
import 'models/editing_recipe_ingredient.dart';

class EditRecipeBloc extends AppCubit<void> {
  final SaveRecipeUseCase saveRecipeUseCase;
  final GetIngredientUseCase getIngredientUseCase;
  final GetRecipeUseCase getRecipeUseCase;
  final GetRecipeCostUseCase getRecipeCostUseCase;

  EditRecipeBloc(
    this.saveRecipeUseCase,
    this.getIngredientUseCase,
    this.getRecipeUseCase,
    this.getRecipeCostUseCase,
  ) : super(const EmptyState());

  Future<ScreenState<void>> save(Recipe recipe) async {
    await runEither(() => saveRecipeUseCase.execute(recipe));
    return state;
  }

  Future<Either<Failure, double>> getCost(Recipe recipe) {
    return getRecipeCostUseCase.execute(recipe);
  }

  Future<Either<Failure, List<EditingRecipeIngredient>>>
      getEditingRecipeIngredients(
    Recipe recipe,
  ) async {
    final futures = recipe.ingredients.map(getEditingRecipeIngredient);
    final results = await Future.wait(futures);
    return results.asEitherList();
  }

  Future<Either<Failure, EditingRecipeIngredient>> getEditingRecipeIngredient(
      RecipeIngredient recipeIngredient) {
    if (recipeIngredient.type == RecipeIngredientType.recipe) {
      return _createEditingRecipeIngredientFromRecipe(recipeIngredient);
    } else {
      return _createEditingRecipeIngredientFromIngredient(recipeIngredient);
    }
  }

  Future<Either<Failure, EditingRecipeIngredient>>
      _createEditingRecipeIngredientFromRecipe(
          RecipeIngredient recipeIngredient) {
    return getRecipeUseCase.execute(recipeIngredient.id).onRightThen(
          (recipe) => getRecipeCostUseCase.execute(recipe!).onRightThen(
                (recipeCost) => Right(
                  EditingRecipeIngredient.fromModels(
                    recipeIngredient,
                    recipe: recipe,
                    recipeCost: recipeCost,
                  ),
                ),
              ),
        );
  }

  Future<Either<Failure, EditingRecipeIngredient>>
      _createEditingRecipeIngredientFromIngredient(
          RecipeIngredient recipeIngredient) {
    return getIngredientUseCase.execute(recipeIngredient.id).onRightThen(
          (ingredient) => Right(
            EditingRecipeIngredient.fromModels(
              recipeIngredient,
              ingredient: ingredient,
            ),
          ),
        );
  }

  double calculateProfitPerQuantitySold({
    required double quantityProduced,
    required double quantitySold,
    required double pricePerQuantitySold,
    required double totalCost,
  }) {
    final quantitySoldRatio = quantityProduced / quantitySold;
    final costPerQuantitySold = totalCost / quantitySoldRatio;
    final profitPerQuantitySold = pricePerQuantitySold - costPerQuantitySold;
    return profitPerQuantitySold;
  }

  double calculateTotalProfit({
    required double quantityProduced,
    required double quantitySold,
    required double pricePerQuantitySold,
    required double totalCost,
  }) {
    final quantitySoldRatio = quantityProduced / quantitySold;
    final totalRecipeSellingPrice = pricePerQuantitySold * quantitySoldRatio;
    final profit = totalRecipeSellingPrice - totalCost;
    return profit;
  }
}
