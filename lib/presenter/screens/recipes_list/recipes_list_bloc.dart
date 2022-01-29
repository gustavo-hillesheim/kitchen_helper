import '../../../domain/domain.dart';
import '../../presenter.dart';
import '../states.dart';

class RecipesListBloc extends AppCubit<List<ListingRecipeDto>>
    with ListPageBloc<ListingRecipeDto, Recipe> {
  @override
  final GetRecipesUseCase getAllUseCase;
  @override
  final DeleteRecipeUseCase deleteUseCase;
  @override
  final SaveRecipeUseCase saveUseCase;
  @override
  final GetRecipeUseCase getUseCase;

  RecipesListBloc(
    this.getAllUseCase,
    this.deleteUseCase,
    this.saveUseCase,
    this.getUseCase,
  ) : super(const LoadingState());
}
