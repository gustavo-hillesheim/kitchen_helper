import 'package:bloc_test/bloc_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/modules/orders/orders.dart';
import 'package:kitchen_helper/modules/orders/presenter/screen/orders_list/widgets/order_list_tile_bloc.dart';
import 'package:kitchen_helper/presenter/screens/states.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../../mocks.dart';

void main() {
  late OrderListTileBloc bloc;
  late GetListingOrderProductsUseCase getListingOrderProductsUseCase;

  void setup() {
    getListingOrderProductsUseCase = GetListingOrderProductsUseCaseMock();
    bloc = OrderListTileBloc(getListingOrderProductsUseCase);
  }

  blocTest<OrderListTileBloc, ScreenState<List<ListingOrderProductDto>>>(
    'WHEN loadsProducts SHOULD return OrderProductData',
    setUp: () {
      setup();
      when(() => getListingOrderProductsUseCase.execute(any()))
          .thenAnswer((_) async => Right(_listingOrderProducts([
                cakeOrderProduct,
                iceCreamOrderProduct,
              ])));
    },
    build: () => bloc,
    expect: () => <ScreenState<List<ListingOrderProductDto>>>[
      const LoadingState(),
      SuccessState(
          _listingOrderProducts([cakeOrderProduct, iceCreamOrderProduct])),
    ],
    act: (bloc) => bloc.loadProducts(batmanOrder.id!),
  );

  blocTest<OrderListTileBloc, ScreenState<List<ListingOrderProductDto>>>(
    'WHEN cannot load products SHOULD return Failure',
    setUp: () {
      setup();
      when(() => getListingOrderProductsUseCase.execute(any()))
          .thenAnswer((_) async => const Left(FakeFailure('could not load')));
    },
    build: () => bloc,
    expect: () => <ScreenState<List<ListingOrderProductDto>>>[
      const LoadingState(),
      const FailureState(FakeFailure('could not load')),
    ],
    act: (bloc) => bloc.loadProducts(batmanOrder.id!),
  );
}

List<ListingOrderProductDto> _listingOrderProducts(
    List<OrderProduct> products) {
  return products
      .map((p) => ListingOrderProductDto(
            quantity: p.quantity,
            measurementUnit: recipesMap[p.id]!.measurementUnit,
            name: recipesMap[p.id]!.name,
          ))
      .toList();
}
