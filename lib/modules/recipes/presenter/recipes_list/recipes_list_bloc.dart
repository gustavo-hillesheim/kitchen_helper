import '../../../../presenter/screens/states.dart';
import '../../../../presenter/widgets/widgets.dart';
import '../../recipes.dart';

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
