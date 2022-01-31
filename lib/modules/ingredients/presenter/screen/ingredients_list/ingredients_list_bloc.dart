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
}
