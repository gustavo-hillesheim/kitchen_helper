import 'package:bloc/bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/presenter/screens/states.dart';

import '../../../core/core.dart';
import '../../../domain/domain.dart';

class IngredientsListBloc extends Cubit<ScreenState<List<Ingredient>>> {
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
