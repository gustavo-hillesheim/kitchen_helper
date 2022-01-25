import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' hide Order;
import 'package:kitchen_helper/core/core.dart';
import 'package:kitchen_helper/database/sqlite/sqlite.dart';
import 'package:kitchen_helper/domain/domain.dart';
import 'package:mocktail/mocktail.dart';

import '../../../mocks.dart';

void main() {
  late ImportUseCase usecase;
  late IngredientRepository ingredientRepository;
  late RecipeRepository recipeRepository;
  late OrderRepository orderRepository;
  late SQLiteDatabase database;

  setUp(() {
    registerFallbackValue(FakeIngredient());
    registerFallbackValue(FakeRecipe());
    registerFallbackValue(FakeOrder());
    ingredientRepository = IngredientRepositoryMock();
    recipeRepository = RecipeRepositoryMock();
    orderRepository = OrderRepositoryMock();
    database = SQLiteDatabaseMock();
    usecase = ImportUseCase(
      ingredientRepository,
      recipeRepository,
      orderRepository,
      database,
    );
  });

  test('SHOULD call repositories correctly', () async {
    when(() => ingredientRepository.save(any())).thenAnswer(
      (invocation) async => Right(invocation.positionalArguments[0].id),
    );
    when(() => recipeRepository.save(any())).thenAnswer(
      (invocation) async => Right(invocation.positionalArguments[0].id),
    );
    when(() => orderRepository.save(any())).thenAnswer(
      (invocation) async => Right(invocation.positionalArguments[0].id),
    );
    when(() => database.insideTransaction(any()))
        .thenAnswer((invocation) async {
      final action = invocation.positionalArguments[0];
      final result = await action() as Either<Failure, void>;
      verify(() => ingredientRepository.save(pineappleIngredient));
      verify(() => recipeRepository.save(pineapplePieRecipe));
      verify(() => orderRepository.save(testClientOrder));
      return result;
    });

    final result = await usecase.execute(data);

    expect(result.isRight(), true);
    verify(() => database.insideTransaction(any()));
  });

  test('WHEN a repository fails SHOULD stop process', () async {
    when(() => ingredientRepository.save(any())).thenAnswer(
      (invocation) async => Right(invocation.positionalArguments[0].id),
    );
    when(() => recipeRepository.save(any())).thenAnswer(
      (_) async => const Left(FakeFailure('failure')),
    );
    when(() => database.insideTransaction(any()))
        .thenAnswer((invocation) async {
      final action = invocation.positionalArguments[0];
      final result = await action() as Either<Failure, void>;
      verify(() => ingredientRepository.save(pineappleIngredient));
      verify(() => recipeRepository.save(pineapplePieRecipe));
      verifyNever(() => orderRepository.save(any()));
      return result;
    });

    final result = await usecase.execute(data);

    expect(result.isLeft(), true);
    expect(result.getLeft().toNullable()?.message, 'failure');
    verify(() => database.insideTransaction(any()));
  });
}

const pineappleIngredient = Ingredient(
  id: 1,
  name: 'pineapple',
  quantity: 1,
  measurementUnit: MeasurementUnit.units,
  cost: 6,
);

const pineapplePieRecipe = Recipe(
  id: 1,
  name: 'pineapple pie',
  quantityProduced: 1,
  canBeSold: true,
  measurementUnit: MeasurementUnit.units,
  quantitySold: 1,
  price: 15,
  notes: 'Some notes',
  ingredients: [
    RecipeIngredient.ingredient(1, quantity: 1),
  ],
);

final testClientOrder = Order(
  id: 1,
  clientName: 'Test client',
  clientAddress: 'Test address',
  orderDate: DateTime(2022, 1, 1, 12),
  deliveryDate: DateTime(2022, 1, 2, 12),
  status: OrderStatus.delivered,
  products: const [
    OrderProduct(
      id: 1,
      quantity: 5,
    ),
  ],
  discounts: const [],
);

final data = {
  'ingredients': [pineappleIngredient.toJson()],
  'recipes': [pineapplePieRecipe.toJson()],
  'orders': [testClientOrder.toJson()]
};
