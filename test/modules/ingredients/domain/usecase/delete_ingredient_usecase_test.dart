import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/modules/ingredients/ingredients.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../mocks.dart';

void main() {
  late DeleteIngredientUseCase usecase;
  late IngredientRepository repository;

  setUp(() {
    repository = IngredientRepositoryMock();
    usecase = DeleteIngredientUseCase(repository);
  });

  test('WHEN called SHOULD delete the ingredient', () async {
    when(() => repository.deleteById(any()))
        .thenAnswer((_) async => const Right(null));

    final result = await usecase.execute(sugarWithId.id!);

    expect(result.isRight(), true);
    verify(() => repository.deleteById(sugarWithId.id!));
  });

  test('WHEN ingredient returns a Failure SHOULD return a Failure too',
      () async {
    when(() => repository.deleteById(any()))
        .thenAnswer((_) async => Left(FakeFailure('delete error')));

    final result = await usecase.execute(sugarWithId.id!);

    expect(result.getLeft().toNullable()?.message, 'delete error');
    verify(() => repository.deleteById(sugarWithId.id!));
  });
}
