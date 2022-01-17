import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/core/core.dart';
import 'package:kitchen_helper/domain/domain.dart';
import 'package:kitchen_helper/presenter/screens/orders_list/widgets/order_list_tile_bloc.dart';
import 'package:kitchen_helper/presenter/screens/states.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../mocks.dart';

void main() {
  late OrderListTileBloc bloc;
  late GetRecipeUseCase getRecipeUseCase;
  late GetOrderPriceUseCase getOrderPriceUseCase;

  void setup() {
    getRecipeUseCase = GetRecipeUseCaseMock();
    getOrderPriceUseCase = GetOrderPriceUseCaseMock();
    bloc = OrderListTileBloc(getRecipeUseCase, getOrderPriceUseCase);
  }

  blocTest<OrderListTileBloc, ScreenState<List<OrderProductData>>>(
    'WHEN loadsProducts SHOULD return OrderProductData',
    setUp: () {
      setup();
      when(() => getRecipeUseCase.execute(any()))
          .thenAnswer((invocation) async {
        final id = invocation.positionalArguments[0];
        return Right(recipesMap[id]!);
      });
    },
    build: () => bloc,
    expect: () => <ScreenState<List<OrderProductData>>>[
      const LoadingState(),
      SuccessState(_productData([cakeOrderProduct, iceCreamOrderProduct])),
    ],
    act: (bloc) => bloc.loadProducts(batmanOrder),
  );

  blocTest<OrderListTileBloc, ScreenState<List<OrderProductData>>>(
    'WHEN cannot load products SHOULD return Failure',
    setUp: () {
      setup();
      when(() => getRecipeUseCase.execute(any()))
          .thenAnswer((_) async => const Left(FakeFailure('could not load')));
    },
    build: () => bloc,
    expect: () => <ScreenState<List<OrderProductData>>>[
      const LoadingState(),
      const FailureState(FakeFailure('could not load')),
    ],
    act: (bloc) => bloc.loadProducts(batmanOrder),
  );

  blocTest<OrderListTileBloc, ScreenState<List<OrderProductData>>>(
    'WHEN finds no products SHOULD return Failure',
    setUp: () {
      setup();
      when(() => getRecipeUseCase.execute(any()))
          .thenAnswer((_) async => const Right(null));
    },
    build: () => bloc,
    expect: () => <ScreenState<List<OrderProductData>>>[
      const LoadingState(),
      FailureState(BusinessFailure(
          'Não foi possível encontrar o produto ${cakeOrderProduct.id}')),
    ],
    act: (bloc) => bloc.loadProducts(batmanOrder),
  );

  test('WHEN getPrice is called SHOULD call getOrderPriceUseCase', () async {
    setup();
    when(() => getOrderPriceUseCase.execute(batmanOrder))
        .thenAnswer((_) async => const Right(10));

    final result = await bloc.getPrice(batmanOrder);

    expect(result.getRight().toNullable(), 10);
  });

  test('WHEN getOrderPriceUseCase return Failure SHOULD return Failure',
      () async {
    setup();
    when(() => getOrderPriceUseCase.execute(batmanOrder))
        .thenAnswer((_) async => const Left(FakeFailure('failure')));

    final result = await bloc.getPrice(batmanOrder);

    expect(result.getLeft().toNullable()?.message, 'failure');
  });
}

List<OrderProductData> _productData(List<OrderProduct> products) {
  return products
      .map((p) => OrderProductData(
            quantity: p.quantity,
            measurementUnit: recipesMap[p.id]!.measurementUnit,
            name: recipesMap[p.id]!.name,
          ))
      .toList();
}
