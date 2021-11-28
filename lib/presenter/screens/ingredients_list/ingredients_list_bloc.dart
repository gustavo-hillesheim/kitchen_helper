import 'package:bloc/bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../core/failure.dart';
import '../../../core/usecase.dart';
import '../../../domain/models/ingredient.dart';
import '../../../domain/usecases/delete_ingredient_usecase.dart';
import '../../../domain/usecases/get_ingredients_usecase.dart';
import '../../../domain/usecases/save_ingredient_usecase.dart';

class IngredientsListBloc extends Cubit<List<Ingredient>?> {
  final GetIngredientsUseCase getIngredientsUseCase;
  final SaveIngredientUseCase saveIngredientUseCase;
  final DeleteIngredientUseCase deleteIngredientsUseCase;

  IngredientsListBloc(
    this.getIngredientsUseCase,
    this.saveIngredientUseCase,
    this.deleteIngredientsUseCase,
  ) : super(null);

  void loadIngredients() async {
    emit(null);
    await Future.delayed(const Duration(seconds: 1));
    final result = await getIngredientsUseCase.execute(const NoParams());
    if (result.isRight()) {
      final ingredients = result.getRight().toNullable();
      emit(ingredients);
    }
  }

  Future<Either<Failure, void>> delete(Ingredient ingredient) async {
    return deleteIngredientsUseCase.execute(ingredient).then((result) {
      loadIngredients();
      return result;
    });
  }

  Future<Either<Failure, Ingredient>> save(Ingredient ingredient) async {
    return saveIngredientUseCase.execute(ingredient).then((result) {
      loadIngredients();
      return result;
    });
  }
}
