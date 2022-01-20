import '../../../domain/domain.dart';
import '../../presenter.dart';
import '../states.dart';

class IngredientsListBloc extends AppCubit<List<Ingredient>>
    with ListPageBloc<Ingredient> {
  @override
  final GetIngredientsUseCase getUseCase;
  @override
  final SaveIngredientUseCase saveUseCase;
  @override
  final DeleteIngredientUseCase deleteUseCase;

  IngredientsListBloc(
    this.getUseCase,
    this.saveUseCase,
    this.deleteUseCase,
  ) : super(const LoadingState());
}
