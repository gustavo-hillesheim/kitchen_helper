import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/common/common.dart';
import 'package:kitchen_helper/core/core.dart';
import 'package:kitchen_helper/modules/recipes/presenter/screen/recipes_list/recipes_list_bloc.dart';
import 'package:kitchen_helper/modules/recipes/recipes.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../mocks.dart';

void main() {
  late SaveRecipeUseCase saveRecipeUseCase;
  late GetRecipesUseCase getRecipesUseCase;
  late DeleteRecipeUseCase deleteRecipeUseCase;
  late GetRecipeUseCase getRecipeUseCase;
  late RecipesListBloc bloc;

  void setup() {
    registerFallbackValue(const RecipesFilter());
    registerFallbackValue(FakeRecipe());
    registerFallbackValue(const NoParams());
    saveRecipeUseCase = SaveRecipeUseCaseMock();
    getRecipesUseCase = GetRecipesUseCaseMock();
    deleteRecipeUseCase = DeleteRecipeUseCaseMock();
    getRecipeUseCase = GetRecipeUseCaseMock();
    bloc = RecipesListBloc(
      getRecipesUseCase,
      deleteRecipeUseCase,
      saveRecipeUseCase,
      getRecipeUseCase,
    );
  }

  blocTest<RecipesListBloc, ScreenState<List<ListingRecipeDto>>>(
    'WHEN loadRecipes is called '
    'SHOULD call getRecipesUseCase',
    setUp: () {
      setup();
      final getResponses = <Either<Failure, List<ListingRecipeDto>>>[
        const Right([]),
        Left(FakeFailure('get error'))
      ];
      when(() => getRecipesUseCase.execute(any()))
          .thenAnswer((_) async => getResponses.removeAt(0));
    },
    build: () => bloc,
    expect: () => <ScreenState<List<ListingRecipeDto>>>[
      const LoadingState(),
      const SuccessState([]),
      const LoadingState(),
      FailureState(FakeFailure('get error')),
    ],
    act: (bloc) async {
      await bloc.load();
      await bloc.load();
    },
    verify: (_) {
      verify(() => getRecipesUseCase.execute());
    },
  );

  blocTest<RecipesListBloc, ScreenState<List<ListingRecipeDto>>>(
    'WHEN delete is called '
    'SHOULD call deleteRecipeUseCase '
    'AND getRecipesUseCase AND return delete response',
    setUp: () {
      setup();
      final deleteResponses = <Either<Failure, void>>[
        const Right(null),
        Left(FakeFailure('error'))
      ];
      when(() => deleteRecipeUseCase.execute(any()))
          .thenAnswer((_) async => deleteResponses.removeAt(0));
      when(() => getRecipeUseCase.execute(any()))
          .thenAnswer((_) async => Right(cakeRecipe));
      when(() => getRecipesUseCase.execute(any()))
          .thenAnswer((_) async => const Right([]));
    },
    build: () => bloc,
    expect: () => <ScreenState<List<ListingRecipeDto>>>[
      const LoadingState(),
      const SuccessState([]),
      const LoadingState(),
      const SuccessState([]),
    ],
    act: (bloc) async {
      var result = await bloc.delete(cakeRecipe.id!);
      expect(result.getRight().toNullable(), cakeRecipe);
      result = await bloc.delete(cakeRecipe.id!);
      expect(result.isLeft(), true);
    },
    verify: (_) {
      verify(() => deleteRecipeUseCase.execute(cakeRecipe.id!)).called(2);
      verify(() => getRecipesUseCase.execute()).called(2);
    },
  );

  blocTest<RecipesListBloc, ScreenState<List<ListingRecipeDto>>>(
    'WHEN save is called '
    'SHOULD call saveRecipeUseCase '
    'AND getRecipesUseCase AND return save response',
    setUp: () {
      setup();
      final saveResponses = <Either<Failure, Recipe>>[
        Right(cakeRecipe),
        Left(FakeFailure('error'))
      ];
      when(() => saveRecipeUseCase.execute(any()))
          .thenAnswer((_) async => saveResponses.removeAt(0));
      when(() => getRecipesUseCase.execute(any()))
          .thenAnswer((_) async => const Right([]));
    },
    build: () => bloc,
    expect: () => <ScreenState<List<ListingRecipeDto>>>[
      const LoadingState(),
      const SuccessState([]),
      const LoadingState(),
      const SuccessState([]),
    ],
    act: (bloc) async {
      var result = await bloc.save(cakeRecipe);
      expect(result.isRight(), true);
      result = await bloc.save(cakeRecipe);
      expect(result.isLeft(), true);
    },
    verify: (_) {
      verify(() => saveRecipeUseCase.execute(cakeRecipe)).called(2);
      verify(() => getRecipesUseCase.execute()).called(2);
    },
  );
}
