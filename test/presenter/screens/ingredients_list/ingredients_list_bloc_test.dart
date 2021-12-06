import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/core/usecase.dart';
import 'package:kitchen_helper/domain/usecases/delete_ingredient_usecase.dart';
import 'package:kitchen_helper/domain/usecases/get_ingredients_usecase.dart';
import 'package:kitchen_helper/domain/usecases/save_ingredient_usecase.dart';
import 'package:kitchen_helper/presenter/screens/ingredients_list/ingredients_list_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../../mocks.dart';

void main() {
  late IngredientsListBloc bloc;
  late GetIngredientsUseCase getUseCase;
  late SaveIngredientUseCase saveUseCase;
  late DeleteIngredientUseCase deleteUseCase;

  void createInstances() {
    getUseCase = GetIngredientsUseCaseMock();
    saveUseCase = SaveIngredientUseCaseMock();
    deleteUseCase = DeleteIngredientUseCaseMock();
    bloc = IngredientsListBloc(getUseCase, saveUseCase, deleteUseCase);
  }

  blocTest<IngredientsListBloc, IngredientListState>(
      'Should call usecases according to method calls',
      build: () {
        createInstances();
        final getResponses = [
          [flour, egg, orangeJuice],
          [flour, egg],
          [flour, egg, orangeJuice],
        ];
        when(() => getUseCase.execute(const NoParams()))
            .thenAnswer((_) async => Right(getResponses.removeAt(0)));
        when(() => deleteUseCase.execute(orangeJuice))
            .thenAnswer((_) async => const Right(null));
        when(() => saveUseCase.execute(orangeJuice))
            .thenAnswer((_) async => Right(orangeJuice));
        return bloc;
      },
      expect: () => [
            LoadingState(),
            SuccessState([flour, egg, orangeJuice]),
            LoadingState(),
            SuccessState([flour, egg]),
            LoadingState(),
            SuccessState([flour, egg, orangeJuice]),
          ],
      act: (bloc) async {
        await bloc.loadIngredients();
        await bloc.delete(orangeJuice);
        await bloc.save(orangeJuice);
      },
      verify: (_) {
        verify(() => getUseCase.execute(const NoParams())).called(3);
        verify(() => deleteUseCase.execute(orangeJuice));
        verify(() => saveUseCase.execute(orangeJuice));
      });

  blocTest<IngredientsListBloc, IngredientListState>(
    'Should emit FailureState if loadIngredients fail',
    build: () {
      createInstances();
      when(() => getUseCase.execute(const NoParams()))
          .thenAnswer((_) async => Left(FakeFailure('Some error on load')));
      return bloc;
    },
    expect: () => [
      LoadingState(),
      FailureState(FakeFailure('Some error on load')),
    ],
    act: (bloc) async => await bloc.loadIngredients(),
  );

  test(
      'WHEN DeleteIngredientUseCase fails THEN delete method SHOULD return a '
      'Failure', () async {
    createInstances();
    when(() => deleteUseCase.execute(egg))
        .thenAnswer((_) async => Left(FakeFailure('Delete error')));
    when(() => getUseCase.execute(const NoParams()))
        .thenAnswer((_) async => const Right([]));

    final result = await bloc.delete(egg);

    expect(result.getLeft().toNullable(), FakeFailure('Delete error'));
  });

  test(
      'WHEN SaveIngredientUseCase fails THEN save method SHOULD return a '
      'Failure', () async {
    createInstances();
    when(() => saveUseCase.execute(egg))
        .thenAnswer((_) async => Left(FakeFailure('Save error')));
    when(() => getUseCase.execute(const NoParams()))
        .thenAnswer((_) async => const Right([]));

    final result = await bloc.save(egg);

    expect(result.getLeft().toNullable(), FakeFailure('Save error'));
  });
}
