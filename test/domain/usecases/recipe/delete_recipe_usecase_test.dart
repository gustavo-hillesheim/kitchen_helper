import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/core/core.dart';
import 'package:kitchen_helper/domain/domain.dart';
import 'package:mocktail/mocktail.dart';

import '../../../mocks.dart';

void main() {
  late DeleteRecipeUseCase usecase;
  late RecipeRepository repository;

  setUp(() {
    repository = RecipeRepositoryMock();
    usecase = DeleteRecipeUseCase(repository);
  });

  test('WHEN called SHOULD delete the register', () async {
    when(() => repository.deleteById(any()))
        .thenAnswer((_) async => const Right(null));

    final result = await usecase.execute(cakeRecipe);

    expect(result.isRight(), true);
    verify(() => repository.deleteById(cakeRecipe.id!));
  });

  test('WHEN repository returns a Failure SHOULD return a Failure too',
      () async {
    when(() => repository.deleteById(any()))
        .thenAnswer((_) async => Left(FakeFailure('delete error')));

    final result = await usecase.execute(cakeRecipe);

    expect(result.getLeft().toNullable(), FakeFailure('delete error'));
    verify(() => repository.deleteById(cakeRecipe.id!));
  });

  test('WHEN recipe doesn\'t have an id SHOULD return a Failure', () async {
    final result = await usecase.execute(sugarWithEggRecipeWithoutId);

    expect(
        result.getLeft().toNullable(),
        const BusinessFailure(
            DeleteRecipeUseCase.cantDeleteRecipeWithoutIdMessage));
    verifyNever(() => repository.deleteById(cakeRecipe.id!));
  });
}
