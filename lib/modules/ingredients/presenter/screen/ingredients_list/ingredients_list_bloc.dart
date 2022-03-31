import '../../../../../common/common.dart';
import '../../../ingredients.dart';

class IngredientsListBloc extends AppCubit<List<ListingIngredientDto>>
    with ListPageBloc<ListingIngredientDto, Ingredient> {
  @override
  final GetIngredientsUseCase getAllUseCase;
  @override
  final SaveIngredientUseCase saveUseCase;
  @override
  final DeleteIngredientUseCase deleteUseCase;
  @override
  final GetIngredientUseCase getUseCase;

  IngredientsListBloc(
    this.getAllUseCase,
    this.saveUseCase,
    this.deleteUseCase,
    this.getUseCase,
  ) : super(const LoadingState());

  @override
  Future<void> load([IngredientsFilter? filter]) async {
    emit(const LoadingState<List<ListingIngredientDto>>());
    final result = await getAllUseCase.execute(filter);
    result.fold(
      (failure) => emit(FailureState<List<ListingIngredientDto>>(failure)),
      (value) => emit(SuccessState<List<ListingIngredientDto>>(value)),
    );
  }
}
