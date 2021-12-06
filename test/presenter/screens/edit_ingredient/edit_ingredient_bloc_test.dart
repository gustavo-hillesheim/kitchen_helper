import 'package:bloc_test/bloc_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/domain/domain.dart';
import 'package:kitchen_helper/presenter/screens/edit_ingredient/edit_ingredient_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../../mocks.dart';

void main() {
  late EditIngredientBloc bloc;
  late SaveIngredientUseCase saveUseCase;

  void createInstances() {
    saveUseCase = SaveIngredientUseCaseMock();
    bloc = EditIngredientBloc(saveUseCase);
  }

  blocTest<EditIngredientBloc, EditIngredientState>(
    'When save is successful SHOULD emit SuccessState',
    build: () {
      createInstances();
      when(() => saveUseCase.execute(egg)).thenAnswer((_) async => Right(egg));
      return bloc;
    },
    expect: () => [
      LoadingState(),
      SuccessState(egg),
    ],
    act: (bloc) => bloc.save(egg),
  );

  blocTest<EditIngredientBloc, EditIngredientState>(
    'When save fails SHOULD emit FailureState',
    build: () {
      createInstances();
      when(() => saveUseCase.execute(egg))
          .thenAnswer((_) async => Left(FakeFailure('Error on save')));
      return bloc;
    },
    expect: () => [
      LoadingState(),
      FailureState(FakeFailure('Error on save')),
    ],
    act: (bloc) => bloc.save(egg),
  );
}
