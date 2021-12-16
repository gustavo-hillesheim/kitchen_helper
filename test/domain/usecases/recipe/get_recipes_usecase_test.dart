import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/core/core.dart';
import 'package:kitchen_helper/domain/domain.dart';
import 'package:mocktail/mocktail.dart';

import '../../../mocks.dart';

void main() {
  late GetRecipesUseCase usecase;
  late RecipeRepository repository;

  setUp(() {
    repository = RecipeRepositoryMock();
    usecase = GetRecipesUseCase(repository);
  });

  void mockFindRecipes(Either<Failure, List<Recipe>> response) {
    when(() => repository.findAll()).thenAnswer((_) async => response);
  }

  test('WHEN called SHOULD get recipes', () async {
    mockFindRecipes(Right([cakeRecipe, sugarWithEggRecipeWithId]));

    final result = await usecase.execute(const NoParams());

    expect(
      result.getRight().toNullable(),
      [cakeRecipe, sugarWithEggRecipeWithId],
    );
    verify(() => repository.findAll());
  });

  test('WHEN repository returns Failure SHOULD return Failure', () async {
    final failure = FakeFailure('error');
    mockFindRecipes(Left(failure));

    final result = await usecase.execute(const NoParams());

    expect(result.getLeft().toNullable(), failure);
    verify(() => repository.findAll());
  });
}
