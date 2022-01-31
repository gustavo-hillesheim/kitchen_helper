import 'package:bloc_test/bloc_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/common/common.dart';
import 'package:kitchen_helper/modules/ingredients/ingredients.dart';
import 'package:kitchen_helper/modules/ingredients/presenter/screen/edit_ingredient/edit_ingredient_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../mocks.dart';

void main() {
  late EditIngredientBloc bloc;
  late SaveIngredientUseCase saveUseCase;
  late GetIngredientUseCase getUseCase;

  void createInstances() {
    saveUseCase = SaveIngredientUseCaseMock();
    getUseCase = GetIngredientUseCaseMock();
    bloc = EditIngredientBloc(saveUseCase, getUseCase);
  }

  blocTest<EditIngredientBloc, ScreenState<Ingredient?>>(
    'When save is successful SHOULD emit SuccessState',
    build: () {
      createInstances();
      when(() => saveUseCase.execute(egg))
          .thenAnswer((_) async => const Right(egg));
      return bloc;
    },
    expect: () => <ScreenState<Ingredient>>[
      const LoadingState(),
      const SuccessState(egg),
    ],
    act: (bloc) => bloc.save(egg),
  );

  blocTest<EditIngredientBloc, ScreenState<Ingredient?>>(
    'When save fails SHOULD emit FailureState',
    build: () {
      createInstances();
      when(() => saveUseCase.execute(egg))
          .thenAnswer((_) async => const Left(FakeFailure('Error on save')));
      return bloc;
    },
    expect: () => <ScreenState<Ingredient>>[
      const LoadingState(),
      const FailureState(FakeFailure('Error on save')),
    ],
    act: (bloc) => bloc.save(egg),
  );
}
