import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/domain/domain.dart';
import 'package:kitchen_helper/presenter/screens/edit_recipe/edit_recipe_bloc.dart';
import 'package:kitchen_helper/presenter/screens/edit_recipe/models/editing_recipe_ingredient.dart';
import 'package:kitchen_helper/presenter/screens/states.dart';
import 'package:mocktail/mocktail.dart';

import '../../../mocks.dart';

void main() {
  late EditRecipeBloc bloc;
  late SaveRecipeUseCase saveRecipeUseCase;
  late GetRecipeUseCase getRecipeUseCase;
  late GetIngredientUseCase getIngredientUseCase;
  late GetRecipeCostUseCase getRecipeCostUseCase;

  void setup() {
    registerFallbackValue(FakeRecipe());
    saveRecipeUseCase = SaveRecipeUseCaseMock();
    getRecipeUseCase = GetRecipeUseCaseMock();
    getIngredientUseCase = GetIngredientUseCaseMock();
    getRecipeCostUseCase = GetRecipeCostUseCaseMock();
    bloc = EditRecipeBloc(
      saveRecipeUseCase,
      getIngredientUseCase,
      getRecipeUseCase,
      getRecipeCostUseCase,
    );
  }

  blocTest<EditRecipeBloc, ScreenState>(
    'WHEN save is successful SHOULD emit SuccessState',
    setUp: () {
      setup();
      when(() => saveRecipeUseCase.execute(any())).thenAnswer(
        (invocation) async => Right(invocation.positionalArguments[0]),
      );
    },
    build: () => bloc,
    expect: () => <ScreenState<Recipe>>[
      const LoadingState(),
      // The BLoC actually emits the recipe being saved,
      // this is allowed because any type can fill a void field
      SuccessState(sugarWithEggRecipeWithId),
    ],
    act: (bloc) => bloc.save(sugarWithEggRecipeWithId),
  );

  blocTest<EditRecipeBloc, ScreenState>(
    'WHEN save fails SHOULD emit FailureState',
    setUp: () {
      setup();
      when(() => saveRecipeUseCase.execute(any())).thenAnswer(
        (invocation) async => const Left(FakeFailure('some error')),
      );
    },
    build: () => bloc,
    expect: () => <ScreenState<Recipe>>[
      const LoadingState(),
      const FailureState(FakeFailure('some error')),
    ],
    act: (bloc) => bloc.save(sugarWithEggRecipeWithId),
  );

  test('WHEN getCost is called SHOULD called getRecipeCostUseCase', () async {
    when(() => getRecipeCostUseCase.execute(any())).thenAnswer(
      (_) async => const Right(10),
    );

    final result = await bloc.getCost(cakeRecipe);

    expect(result, const Right(10));

    verify(() => getRecipeCostUseCase.execute(cakeRecipe));
  });

  test(
    'WHEN getEditingRecipeIngredients is called SHOULD convert the recipe'
    '\'s ingredients to EditingRecipeIngredients',
    () async {
      when(() => getRecipeCostUseCase.execute(any())).thenAnswer(
        (_) async => const Right(10),
      );
      when(() => getRecipeUseCase.execute(any())).thenAnswer(
        (_) async => Right(sugarWithEggRecipeWithId),
      );
      when(() => getIngredientUseCase.execute(any())).thenAnswer(
        (_) async => const Right(flour),
      );

      final result = await bloc.getEditingRecipeIngredients(cakeRecipe);

      expect(result.isRight(), true);
      expect(
        result.getRight().toNullable(),
        [
          EditingRecipeIngredient(
            id: flour.id!,
            name: flour.name,
            quantity: 1,
            measurementUnit: flour.measurementUnit,
            cost: flour.cost,
            type: RecipeIngredientType.ingredient,
          ),
          EditingRecipeIngredient(
            id: sugarWithEggRecipeWithId.id!,
            name: sugarWithEggRecipeWithId.name,
            quantity: 5,
            measurementUnit: sugarWithEggRecipeWithId.measurementUnit,
            // totalCost * (quantitySold / quantityProduced)
            cost: 10 * (5 / sugarWithEggRecipeWithId.quantityProduced),
            type: RecipeIngredientType.recipe,
          ),
        ],
      );
    },
  );
}
