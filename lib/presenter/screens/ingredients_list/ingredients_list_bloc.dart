import 'package:bloc/bloc.dart';
import 'package:kitchen_helper/core/usecase.dart';
import 'package:kitchen_helper/domain/models/ingredient.dart';
import 'package:kitchen_helper/domain/usecases/get_ingredients_usecase.dart';

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
