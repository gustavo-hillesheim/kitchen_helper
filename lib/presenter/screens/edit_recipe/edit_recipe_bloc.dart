import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/presenter/screens/edit_recipe/models/editing_recipe_ingredient.dart';

import '../../../core/core.dart';
import '../../../domain/domain.dart';
import '../states.dart';

class EditRecipeBloc extends AppCubit<void> {
  final SaveRecipeUseCase usecase;
  final GetIngredientUseCase getIngredientUseCase;
  final GetRecipeUseCase getRecipeUseCase;

  EditRecipeBloc(
    this.usecase,
    this.getIngredientUseCase,
    this.getRecipeUseCase,
  ) : super(const EmptyState());

  Future<ScreenState<void>> save(Recipe recipe) async {
    await runEither(() => usecase.execute(recipe));
    return state;
  }

  Future<Either<Failure, List<EditingRecipeIngredient>>>
      getEditingRecipeIngredients(
    Recipe recipe,
  ) async {
    final futures = recipe.ingredients.map((recipeIngredient) async {
      if (recipeIngredient.type == RecipeIngredientType.recipe) {
        return _createEditingRecipeIngredientFromRecipe(recipeIngredient);
      } else {
        return _createEditingRecipeIngredientFromIngredient(recipeIngredient);
      }
    });
    final results = await Future.wait(futures);
    return results.asEitherList();
  }

  Future<Either<Failure, EditingRecipeIngredient>>
      _createEditingRecipeIngredientFromRecipe(
          RecipeIngredient recipeIngredient) {
    return getRecipeUseCase.execute(recipeIngredient.id).onRightThen(
          (recipe) => Right(
            EditingRecipeIngredient.fromModels(
              recipeIngredient,
              recipe: recipe,
              recipeCost: 5,
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
}
