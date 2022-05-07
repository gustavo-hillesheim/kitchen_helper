import '../../../../../common/common.dart';
import '../../../recipes.dart';

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

  @override
  Future<void> load([RecipesFilter? filter]) async {
    emit(const LoadingState<List<ListingRecipeDto>>());
    final result = await getAllUseCase.execute(filter);
    result.fold(
      (failure) => emit(FailureState<List<ListingRecipeDto>>(failure)),
      (value) => emit(SuccessState<List<ListingRecipeDto>>(value)),
    );
  }
}
