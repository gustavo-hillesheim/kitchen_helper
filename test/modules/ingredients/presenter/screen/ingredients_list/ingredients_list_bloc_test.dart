import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/common/common.dart';
import 'package:kitchen_helper/core/core.dart';
import 'package:kitchen_helper/modules/ingredients/ingredients.dart';
import 'package:kitchen_helper/modules/ingredients/presenter/screen/ingredients_list/ingredients_list_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../mocks.dart';

void main() {
  late IngredientsListBloc bloc;
  late GetIngredientsUseCase getAllUseCase;
  late SaveIngredientUseCase saveUseCase;
  late DeleteIngredientUseCase deleteUseCase;
  late GetIngredientUseCase getUseCase;

  void createInstances() {
    getAllUseCase = GetIngredientsUseCaseMock();
    saveUseCase = SaveIngredientUseCaseMock();
    deleteUseCase = DeleteIngredientUseCaseMock();
    getUseCase = GetIngredientUseCaseMock();
    when(() => getUseCase.execute(any())).thenAnswer((invocation) async {
      final id = invocation.positionalArguments[0];
      return Right(ingredientsMap[id]);
    });
    bloc = IngredientsListBloc(
        getAllUseCase, saveUseCase, deleteUseCase, getUseCase);
  }

  blocTest<IngredientsListBloc, ScreenState<List<ListingIngredientDto>>>(
      'Should call usecases according to method calls',
      build: () {
        createInstances();
        final getResponses = [
          [listingFlourDto, listingEggDto, listingOrangeJuiceDto],
          [listingFlourDto, listingEggDto],
          [listingFlourDto, listingEggDto, listingOrangeJuiceDto],
        ];
        when(() => getAllUseCase.execute(const NoParams()))
            .thenAnswer((_) async => Right(getResponses.removeAt(0)));
        when(() => deleteUseCase.execute(orangeJuice.id!))
            .thenAnswer((_) async => const Right(null));
        when(() => saveUseCase.execute(orangeJuice))
            .thenAnswer((_) async => const Right(orangeJuice));
        return bloc;
      },
      expect: () => <ScreenState<List<ListingIngredientDto>>>[
            const LoadingState(),
            const SuccessState(
                [listingFlourDto, listingEggDto, listingOrangeJuiceDto]),
            const LoadingState(),
            const SuccessState([listingFlourDto, listingEggDto]),
            const LoadingState(),
            const SuccessState(
                [listingFlourDto, listingEggDto, listingOrangeJuiceDto]),
          ],
      act: (bloc) async {
        await bloc.load();
        await bloc.delete(orangeJuice.id!);
        await bloc.save(orangeJuice);
      },
      verify: (_) {
        verify(() => getAllUseCase.execute(const NoParams())).called(3);
        verify(() => deleteUseCase.execute(orangeJuice.id!));
        verify(() => saveUseCase.execute(orangeJuice));
      });

  blocTest<IngredientsListBloc, ScreenState<List<ListingIngredientDto>>>(
    'Should emit FailureState if load fail',
    build: () {
      createInstances();
      when(() => getAllUseCase.execute(const NoParams()))
          .thenAnswer((_) async => Left(FakeFailure('Some error on '
              'load')));
      return bloc;
    },
    expect: () => <ScreenState<List<ListingIngredientDto>>>[
      const LoadingState(),
      FailureState(FakeFailure('Some error on load')),
    ],
    act: (bloc) async => await bloc.load(),
  );

  test(
      'WHEN DeleteIngredientUseCase fails THEN delete method SHOULD return a '
      'Failure', () async {
    createInstances();
    when(() => deleteUseCase.execute(egg.id!))
        .thenAnswer((_) async => Left(FakeFailure('Delete error')));
    when(() => getAllUseCase.execute(const NoParams()))
        .thenAnswer((_) async => const Right([]));

    final result = await bloc.delete(egg.id!);

    expect(result.getLeft().toNullable(), FakeFailure('Delete error'));
  });

  test(
      'WHEN SaveIngredientUseCase fails THEN save method SHOULD return a '
      'Failure', () async {
    createInstances();
    when(() => saveUseCase.execute(egg))
        .thenAnswer((_) async => Left(FakeFailure('Save error')));
    when(() => getAllUseCase.execute(const NoParams()))
        .thenAnswer((_) async => const Right([]));

    final result = await bloc.save(egg);

    expect(result.getLeft().toNullable(), FakeFailure('Save error'));
  });
}
