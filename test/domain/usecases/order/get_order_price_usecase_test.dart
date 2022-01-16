import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' hide Order;
import 'package:kitchen_helper/domain/domain.dart';
import 'package:mocktail/mocktail.dart';

import '../../../mocks.dart';

void main() {
  late GetOrderPriceUseCase usecase;
  late GetRecipeUseCase getRecipeUseCase;

  final testOrder = Order(
    clientName: '',
    clientAddress: '',
    status: OrderStatus.delivered,
    discounts: const [],
    products: [
      OrderProduct(id: cakeRecipe.id!, quantity: 1),
      OrderProduct(id: iceCreamRecipe.id!, quantity: 4),
    ],
    orderDate: DateTime.now(),
    deliveryDate: DateTime.now(),
  );

  setUp(() {
    getRecipeUseCase = GetRecipeUseCaseMock();
    usecase = GetOrderPriceUseCase(getRecipeUseCase);
    when(() => getRecipeUseCase.execute(cakeRecipe.id!))
        .thenAnswer((_) async => Right(cakeRecipe));
    when(() => getRecipeUseCase.execute(iceCreamRecipe.id!))
        .thenAnswer((_) async => Right(iceCreamRecipe));
  });

  test('SHOULD calculate price of order', () async {
    final result = await usecase.execute(testOrder);

    expect(result.getRight().toNullable(), 50);
  });

  test('WHEN recipe has discount SHOULD calculate discounted price', () async {
    final result = await usecase.execute(testOrder.copyWith(
      discounts: [
        const Discount(reason: '', type: DiscountType.fixed, value: 10),
        const Discount(reason: '', type: DiscountType.percentage, value: 10),
      ],
    ));

    expect(result.getRight().toNullable(), 35);
  });

  test('WHEN getRecipeUseCase return Failure SHOULD return Failure', () async {
    when(() => getRecipeUseCase.execute(any()))
        .thenAnswer((_) async => const Left(FakeFailure('failure')));

    final result = await usecase.execute(testOrder);

    expect(result.getLeft().toNullable()?.message, 'failure');
  });
}
