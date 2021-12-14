import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/domain/domain.dart';
import 'package:mocktail/mocktail.dart';

import '../../../mocks.dart';

void main() {
  late GetRecipeUseCase usecase;
  late RecipeRepository repository;

  setUp(() {
    repository = RecipeRepositoryMock();
    usecase = GetRecipeUseCase(repository);
  });

  test('WHEN called SHOULD return the register', () async {
    when(() => repository.findById(any()))
        .thenAnswer((_) async => Right(cakeRecipe));

    final result = await usecase.execute(cakeRecipe.id!);

    expect(result.getRight().toNullable(), cakeRecipe);
    verify(() => repository.findById(cakeRecipe.id!));
  });

  test('WHEN repository returns Failure SHOULD return Failure too', () async {
    when(() => repository.findById(any()))
        .thenAnswer((_) async => Left(FakeFailure('error on get')));

    final result = await usecase.execute(cakeRecipe.id!);

    expect(result.getLeft().toNullable(), FakeFailure('error on get'));
    verify(() => repository.findById(cakeRecipe.id!));
  });
}
