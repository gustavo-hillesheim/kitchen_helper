import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/core/core.dart';
import 'package:kitchen_helper/modules/recipes/recipes.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../mocks.dart';

typedef FindAllResponse = Future<Either<Failure, List<RecipeDomainDto>>>;

void main() {
  late RecipeRepository repository;
  late GetRecipesDomainUseCase usecase;

  setUp(() {
    registerFallbackValue(const RecipeFilter());
    repository = RecipeRepositoryMock();
    usecase = GetRecipesDomainUseCase(repository);
  });

  When<FindAllResponse> mockFindAllDomain() {
    return when(() => repository.findAllDomain(filter: any(named: 'filter')));
  }

  test('WHEN has no filter SHOULD return all records', () async {
    mockFindAllDomain().thenAnswer((_) async => const Right([
          cakeRecipeDomain,
          iceCreamRecipeDomain,
          sugarWithEggRecipeDomain,
        ]));

    final result = await usecase.execute(null);

    expect(result.getRight().toNullable(), [
      cakeRecipeDomain,
      iceCreamRecipeDomain,
      sugarWithEggRecipeDomain,
    ]);
  });

  test('WHEN has filter SHOULD pass it to repository', () async {
    mockFindAllDomain().thenAnswer((_) async => const Right([
          cakeRecipeDomain,
          iceCreamRecipeDomain,
        ]));

    final result =
        await usecase.execute(const RecipeDomainFilter(canBeSold: true));

    expect(result.getRight().toNullable(), [
      cakeRecipeDomain,
      iceCreamRecipeDomain,
    ]);
  });

  test('WHEN has recipe to ignore SHOULD remove recipes that depend on it',
      () async {
    mockFindAllDomain().thenAnswer(
        // Can not be const because the list will be modified
        (_) async => const Right([cakeRecipeDomain, iceCreamRecipeDomain]));
    when(() => repository.getRecipesThatDependOn(any())).thenAnswer(
        (_) async => Right({cakeRecipeDomain.id, iceCreamRecipeDomain.id}));

    final result = await usecase.execute(const RecipeDomainFilter(
      canBeSold: true,
      ignoreRecipesThatDependOn: 1,
    ));

    expect(result.getRight().toNullable(), []);
  });

  test(
      'WHEN repository returns Failure on findAllDomain '
      'SHOULD return Failure', () async {
    mockFindAllDomain()
        .thenAnswer((_) async => Left(FakeFailure('find failure')));

    final result = await usecase.execute(null);

    expect(result.getLeft().toNullable()?.message, 'find failure');
  });

  test(
      'WHEN repository returns Failure on getRecipesThatDependOn '
      'SHOULD return Failure', () async {
    mockFindAllDomain().thenAnswer((_) async => const Right([]));
    when(() => repository.getRecipesThatDependOn(any()))
        .thenAnswer((_) async => Left(FakeFailure('get recipes failure')));

    final result = await usecase.execute(
      const RecipeDomainFilter(ignoreRecipesThatDependOn: 1),
    );

    expect(result.getLeft().toNullable()?.message, 'get recipes failure');
  });
}
