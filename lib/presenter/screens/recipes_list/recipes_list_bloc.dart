import 'package:fpdart/fpdart.dart';

import '../../../core/core.dart';
import '../../../domain/domain.dart';
import '../states.dart';

class RecipesListBloc extends AppCubit<List<ListingRecipeDto>> {
  final GetRecipesUseCase getAllUseCase;
  final DeleteRecipeUseCase deleteUseCase;
  final SaveRecipeUseCase saveUseCase;
  final GetRecipeUseCase getUseCase;

  RecipesListBloc(
    this.getAllUseCase,
    this.deleteUseCase,
    this.saveUseCase,
    this.getUseCase,
  ) : super(const LoadingState());

  Future<void> loadRecipes() async {
    await runEither(() => getAllUseCase.execute(const NoParams()));
  }

  Future<Either<Failure, Recipe>> delete(int id) async {
    final getResult = await getUseCase.execute(id);
    return getResult.bindFuture<Recipe>((recipe) async {
      if (recipe == null) {
        return const Left(BusinessFailure('Receita não encontrada'));
      }
      return deleteUseCase.execute(id).then((result) {
        loadRecipes();
        return result.map((_) => recipe);
      });
    }).run();
  }

  Future<Either<Failure, Recipe>> save(Recipe recipe) async {
    return saveUseCase.execute(recipe).then((result) {
      loadRecipes();
      return result;
    });
  }
}
