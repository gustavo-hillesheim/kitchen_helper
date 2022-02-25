import 'package:fpdart/fpdart.dart';

import '../../../../../common/common.dart';
import '../../../../../core/core.dart';
import '../../../ingredients.dart';

class EditIngredientBloc extends AppCubit<Ingredient> {
  final SaveIngredientUseCase usecase;
  final GetIngredientUseCase getUseCase;

  EditIngredientBloc(this.usecase, this.getUseCase) : super(const EmptyState());

  Future<Either<Failure, void>> save(Ingredient ingredient) async {
    return runEither(() => usecase.execute(ingredient));
  }

  Future<void> loadIngredient(int id) async {
    emit(const LoadingIngredientState());
    final result = await getUseCase.execute(id);
    result.fold(
      (f) => emit(FailureState(f)),
      (ingredient) {
        if (ingredient == null) {
          emit(FailureState(
            BusinessFailure('Não foi possível encontrar o ingrediente'),
          ));
        } else {
          emit(SuccessState(ingredient));
        }
      },
    );
  }
}

class LoadingIngredientState extends ScreenState<Ingredient> {
  const LoadingIngredientState();
}
