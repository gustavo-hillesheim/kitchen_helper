import '../../../domain/domain.dart';
import '../../presenter.dart';
import '../states.dart';

class RecipesListBloc extends AppCubit<List<Recipe>> with ListPageBloc<Recipe> {
  @override
  final GetRecipesUseCase getUseCase;
  @override
  final DeleteRecipeUseCase deleteUseCase;
  @override
  final SaveRecipeUseCase saveUseCase;

  RecipesListBloc(
    this.getUseCase,
    this.deleteUseCase,
    this.saveUseCase,
  ) : super(const LoadingState());
}
