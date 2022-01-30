import 'package:fpdart/fpdart.dart';

import '../../../../core/core.dart';
import '../../../../extensions.dart';
import '../../../../presenter/screens/states.dart';
import '../../../ingredients/ingredients.dart';
import '../../recipes.dart';
import 'models/editing_recipe_ingredient.dart';

class EditRecipeBloc extends AppCubit<Recipe> {
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

  Future<void> loadRecipe(int id) async {
    emit(const LoadingRecipeState());
    final result = await getRecipeUseCase.execute(id);
    result.fold(
      (f) => emit(FailureState(f)),
      (recipe) {
        if (recipe == null) {
          emit(const FailureState(
            BusinessFailure('Não foi possível encontrar a receita'),
          ));
        } else {
          emit(SuccessState(recipe));
        }
      },
    );
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
}

class LoadingRecipeState extends ScreenState<Recipe> {
  const LoadingRecipeState();
}
