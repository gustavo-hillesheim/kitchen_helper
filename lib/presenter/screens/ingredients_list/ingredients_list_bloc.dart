import 'package:fpdart/fpdart.dart';

import '../../../core/core.dart';
import '../../../domain/domain.dart';
import '../states.dart';

class IngredientsListBloc extends AppCubit<List<ListingIngredientDto>> {
  final GetIngredientsUseCase getAllUseCase;
  final SaveIngredientUseCase saveUseCase;
  final DeleteIngredientUseCase deleteUseCase;
  final GetIngredientUseCase getUseCase;

  IngredientsListBloc(
    this.getAllUseCase,
    this.saveUseCase,
    this.deleteUseCase,
    this.getUseCase,
  ) : super(const LoadingState());

  Future<void> loadIngredients() async {
    await runEither(() => getAllUseCase.execute(const NoParams()));
  }

  Future<Either<Failure, Ingredient>> delete(int id) async {
    final getResult = await getUseCase.execute(id);
    return getResult.bindFuture<Ingredient>((ingredient) async {
      if (ingredient == null) {
        return const Left(BusinessFailure('Ingrediente não encontrado'));
      }
      return deleteUseCase.execute(id).then((result) {
        loadIngredients();
        return result.map((_) => ingredient);
      });
    }).run();
  }

  Future<Either<Failure, Ingredient>> save(Ingredient ingredient) async {
    return saveUseCase.execute(ingredient).then((result) {
      loadIngredients();
      return result;
    });
  }
}
