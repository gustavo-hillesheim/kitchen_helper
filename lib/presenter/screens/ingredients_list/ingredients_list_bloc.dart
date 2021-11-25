import 'package:bloc/bloc.dart';

import '../../../core/usecase.dart';
import '../../../domain/models/ingredient.dart';
import '../../../domain/usecases/get_ingredients_usecase.dart'
    show GetIngredientsUseCase;

class IngredientsListBloc extends Cubit<List<Ingredient>?> {
  final GetIngredientsUseCase usecase;

  IngredientsListBloc(this.usecase) : super(null);

  void loadIngredients() async {
    await Future.delayed(const Duration(seconds: 1));
    final result = await usecase.execute(const NoParams());
    if (result.isRight()) {
      final ingredients = result.getRight().toNullable();
      emit(ingredients);
    }
  }
}
