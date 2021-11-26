import 'package:bloc/bloc.dart';

import '../../../core/usecase.dart';
import '../../../domain/models/ingredient.dart';
import '../../../domain/usecases/delete_ingredient_usecase.dart';
import '../../../domain/usecases/get_ingredients_usecase.dart';

class IngredientsListBloc extends Cubit<List<Ingredient>?> {
  final GetIngredientsUseCase getIngredientsUseCase;
  final DeleteIngredientUseCase deleteIngredientsUseCase;

  IngredientsListBloc(
    this.getIngredientsUseCase,
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

  Future<void> delete(Ingredient ingredient) async {
    await deleteIngredientsUseCase.execute(ingredient);
    loadIngredients();
  }
}
