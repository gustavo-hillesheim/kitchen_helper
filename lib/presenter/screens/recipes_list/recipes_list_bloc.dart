import 'package:fpdart/fpdart.dart';

import '../../../core/core.dart';
import '../../../domain/domain.dart';
import '../states.dart';

class RecipesListBloc extends AppCubit<List<Recipe>> {
  final GetRecipesUseCase getRecipesUseCase;
  final DeleteRecipeUseCase deleteRecipeUseCase;
  final SaveRecipeUseCase saveRecipeUseCase;

  RecipesListBloc(
    this.getRecipesUseCase,
    this.deleteRecipeUseCase,
    this.saveRecipeUseCase,
  ) : super(const LoadingState());

  Future<void> loadRecipes() {
    return runEither(() => getRecipesUseCase.execute(const NoParams()));
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
