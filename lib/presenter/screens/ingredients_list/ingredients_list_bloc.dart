import 'package:bloc/bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../core/failure.dart';
import '../../../core/usecase.dart';
import '../../../domain/models/ingredient.dart';
import '../../../domain/usecases/delete_ingredient_usecase.dart';
import '../../../domain/usecases/get_ingredients_usecase.dart';
import '../../../domain/usecases/save_ingredient_usecase.dart';

abstract class IngredientListState {}

class LoadingState extends IngredientListState {}

class SuccessState extends IngredientListState {
  final List<Ingredient> ingredients;
  SuccessState(this.ingredients);
}

class FailureState extends IngredientListState {
  final Failure failure;
  FailureState(this.failure);
}

class IngredientsListBloc extends Cubit<IngredientListState> {
  final GetIngredientsUseCase getIngredientsUseCase;
  final SaveIngredientUseCase saveIngredientUseCase;
  final DeleteIngredientUseCase deleteIngredientsUseCase;

  IngredientsListBloc(
    this.getIngredientsUseCase,
    this.saveIngredientUseCase,
    this.deleteIngredientsUseCase,
  ) : super(LoadingState());

  void loadIngredients() async {
    emit(LoadingState());
    await Future.delayed(const Duration(seconds: 1));
    var result = await getIngredientsUseCase.execute(const NoParams());
    result.fold(
      (failure) => emit(FailureState(failure)),
      (ingredients) => emit(SuccessState(ingredients)),
    );
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
