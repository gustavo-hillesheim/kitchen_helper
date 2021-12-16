import 'package:bloc/bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../core/core.dart';
import '../../../domain/domain.dart';
import '../states.dart';

class RecipesListBloc extends Cubit<ScreenState<List<Recipe>>> {
  final GetRecipesUseCase getRecipesUseCase;
  final DeleteRecipeUseCase deleteRecipeUseCase;
  final SaveRecipeUseCase saveRecipeUseCase;

  RecipesListBloc(
    this.getRecipesUseCase,
    this.deleteRecipeUseCase,
    this.saveRecipeUseCase,
  ) : super(const LoadingState());

  Future<void> loadRecipes() async {
    emit(const LoadingState());
    const recipesMock = <Recipe>[
      Recipe(
        id: 1,
        name: 'Brigadeiro',
        quantityProduced: 500,
        measurementUnit: MeasurementUnit.grams,
        canBeSold: false,
        ingredients: [
          RecipeIngredient.ingredient(1, quantity: 250),
          RecipeIngredient.ingredient(2, quantity: 100),
          RecipeIngredient.ingredient(3, quantity: 200),
        ],
      ),
      Recipe(
        name: 'Torta de bolacha',
        quantityProduced: 1,
        quantitySold: 1,
        canBeSold: true,
        measurementUnit: MeasurementUnit.units,
        price: 50,
        ingredients: [
          RecipeIngredient.ingredient(2, quantity: 150),
          RecipeIngredient.ingredient(15, quantity: 50),
          RecipeIngredient.ingredient(7, quantity: 15),
          RecipeIngredient.recipe(2, quantity: 500),
        ],
      ),
    ];
    await Future.delayed(Duration(seconds: 1));
    emit(SuccessState(recipesMock));
  }

  Future<Either<Failure, void>> delete(Recipe recipe) async {
    return deleteRecipeUseCase.execute(recipe).then((result) {
      loadRecipes();
      return result;
    });
  }

  Future<Either<Failure, Recipe>> save(Recipe recipe) async {
    return saveRecipeUseCase.execute(recipe).then((result) {
      loadRecipes();
      return result;
    });
  }
}
