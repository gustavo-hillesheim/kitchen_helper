import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../core/failure.dart';
import '../../../core/usecase.dart';
import '../../../domain/models/ingredient.dart';
import '../../../domain/usecases/ingredient/delete_ingredient_usecase.dart';
import '../../../domain/usecases/ingredient/get_ingredients_usecase.dart';
import '../../../domain/usecases/ingredient/save_ingredient_usecase.dart';

class IngredientsListBloc extends Cubit<IngredientListState> {
  final GetIngredientsUseCase getIngredientsUseCase;
  final SaveIngredientUseCase saveIngredientUseCase;
  final DeleteIngredientUseCase deleteIngredientsUseCase;

  IngredientsListBloc(
    this.getIngredientsUseCase,
    this.saveIngredientUseCase,
    this.deleteIngredientsUseCase,
  ) : super(LoadingState());

  Future<void> loadIngredients() async {
    emit(LoadingState());
    final result = await getIngredientsUseCase.execute(const NoParams());
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

abstract class IngredientListState extends Equatable {}

class LoadingState extends IngredientListState {
  @override
  List<Object?> get props => [];
}

class SuccessState extends IngredientListState {
  final List<Ingredient> ingredients;
  SuccessState(this.ingredients);

  @override
  List<Object?> get props => [ingredients];
}

class FailureState extends IngredientListState {
  final Failure failure;
  FailureState(this.failure);

  @override
  List<Object?> get props => [failure];
}
