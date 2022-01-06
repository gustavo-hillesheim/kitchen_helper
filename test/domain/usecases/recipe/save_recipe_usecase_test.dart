import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/core/core.dart';
import 'package:kitchen_helper/domain/domain.dart';
import 'package:mocktail/mocktail.dart';

import '../../../mocks.dart';

void main() {
  late SaveRecipeUseCase usecase;
  late RecipeRepository repository;

  setUp(() {
    registerFallbackValue(FakeRecipe());
    repository = RecipeRepositoryMock();
    usecase = SaveRecipeUseCase(repository);
  });

  void mockRecipeRepositorySave(Either<Failure, int> result) {
    when(() => repository.save(any())).thenAnswer((_) async => result);
  }

  test('WHEN called SHOULD save the recipe', () async {
    mockRecipeRepositorySave(const Right(2));

    final result = await usecase.execute(cakeRecipe);

    expect(result.getRight().toNullable(), cakeRecipe.copyWith(id: 2));
    verify(() => repository.save(cakeRecipe));
  });

  test('WHEN repository returns Failure SHOULD return Failure too', () async {
    final failure = FakeFailure('repository failure');
    mockRecipeRepositorySave(Left(failure));

    final result = await usecase.execute(cakeRecipe);

    expect(result.getLeft().toNullable(), failure);
    verify(() => repository.save(cakeRecipe));
  });
}
