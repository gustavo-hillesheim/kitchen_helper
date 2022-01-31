import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/common/common.dart';
import 'package:kitchen_helper/modules/orders/orders.dart';
import 'package:kitchen_helper/modules/orders/presenter/screen/orders_list/orders_list_bloc.dart';
import 'package:kitchen_helper/modules/orders/presenter/screen/orders_list/orders_list_screen.dart';
import 'package:kitchen_helper/modules/orders/presenter/screen/orders_list/widgets/order_filter.dart';
import 'package:kitchen_helper/modules/orders/presenter/screen/orders_list/widgets/order_list_tile.dart';
import 'package:mocktail/mocktail.dart';
import 'package:modular_test/modular_test.dart';

import '../../../../../finders.dart';
import '../../../../../mocks.dart';

void main() {
  late OrdersListBloc bloc;
  late StreamController<ScreenState<List<ListingOrderDto>>> streamController;

  setUp(() {
    registerFallbackValue(FakeOrder());
    streamController = StreamController();
    bloc = OrdersListBlocMock();
    when(() => bloc.stream).thenAnswer((_) => streamController.stream);
  });

  testWidgets('WHEN has no orders SHOULD render empty', (tester) async {
    when(() => bloc.load()).thenAnswer((_) async {
      streamController.sink.add(const SuccessState([]));
    });

    await tester.pumpWidget(MaterialApp(
      home: OrdersListScreen(bloc: bloc),
    ));
    // Renders empty
    await tester.pump();

    expect(find.byType(OrderFilter), findsOneWidget);
    expect(find.text('Pedidos'), findsOneWidget);
    expect(find.text('Adicionar'), findsOneWidget);
    expect(
      EmptyFinder(
        text: 'Sem pedidos',
        subtext: 'Adicione pedidos e eles aparecerão aqui',
      ),
      findsOneWidget,
    );
  });

  testWidgets('WHEN has orders SHOULD render OrderListTile', (tester) async {
    mockOrderListTile();
    when(() => bloc.load()).thenAnswer((_) async {
      streamController.sink.add(SuccessState([listingBatmanOrderDto]));
    });

    await tester.pumpWidget(MaterialApp(
      home: OrdersListScreen(bloc: bloc),
    ));
    // Renders empty
    await tester.pump();
    verify(() => bloc.load());

    expect(find.byType(OrderListTile), findsOneWidget);
  });

  testWidgets('WHEN taps order SHOULD navigate to EditOrderScreen',
      (tester) async {
    mockOrderListTile();
    final navigator = mockNavigator();
    when(
      () => navigator.pushNamed(any(), arguments: any(named: 'arguments')),
    ).thenAnswer((_) async => true);

    when(() => bloc.load()).thenAnswer((_) async {
      streamController.sink.add(SuccessState([listingBatmanOrderDto]));
    });

    await tester.pumpWidget(MaterialApp(
      home: OrdersListScreen(bloc: bloc),
    ));
    // Renders empty
    await tester.pump();

    await tester.tap(find.byType(OrderListTile));
    verify(() => navigator.pushNamed('./edit', arguments: batmanOrder.id));
    verify(() => bloc.load());
  });

  testWidgets('WHEN taps new order SHOULD navigate to EditOrderScreen',
      (tester) async {
    final navigator = mockNavigator();
    when(
      () => navigator.pushNamed(any(), arguments: any(named: 'arguments')),
    ).thenAnswer((_) async => false);

    when(() => bloc.load()).thenAnswer((_) async {
      streamController.sink.add(const SuccessState([]));
    });

    await tester.pumpWidget(MaterialApp(
      home: OrdersListScreen(bloc: bloc),
    ));
    // Renders empty
    await tester.pump();
    verify(() => bloc.load());

    await tester.tap(find.text('Adicionar'));
    verify(() => navigator.pushNamed('./edit', arguments: null));
    verifyNever(() => bloc.load());
  });

  testWidgets('WHEN changes filter SHOULD reload', (tester) async {
    when(() => bloc.load(status: any(named: 'status'))).thenAnswer((_) async {
      streamController.sink.add(const SuccessState([]));
    });

    await tester.pumpWidget(MaterialApp(
      home: OrdersListScreen(bloc: bloc),
    ));
    // Renders empty
    await tester.pump();
    verify(() => bloc.load());

    await tester.tap(ToggleableTagFinder(label: 'Não Entregue', value: false));
    verify(() => bloc.load(status: OrderStatus.ordered));
  });

  testWidgets(
      'WHEN navigate to edit screen with filter on AND should reload '
      'SHOULD reload with filter', (tester) async {
    final navigator = mockNavigator();
    when(() => navigator.pushNamed(any())).thenAnswer((_) async => true);
    when(() => bloc.load(status: any(named: 'status'))).thenAnswer((_) async {
      streamController.sink.add(const SuccessState([]));
    });
    await tester.pumpWidget(MaterialApp(
      home: OrdersListScreen(bloc: bloc),
    ));
    // Renders empty
    await tester.pump();

    await tester.tap(ToggleableTagFinder(label: 'Entregue', value: false));
    verify(() => bloc.load(status: OrderStatus.delivered));

    await tester.tap(find.text('Adicionar'));
    await tester.pumpAndSettle();

    verify(() => bloc.load(status: OrderStatus.delivered));
  });
}

void mockOrderListTile() {
  final getListingOrderProductsUseCase = GetListingOrderProductsUseCaseMock();

  initModule(FakeModule([
    Bind.instance<GetListingOrderProductsUseCase>(
        getListingOrderProductsUseCase),
  ]));
}

class FakeModule extends Module {
  @override
  final List<Bind> binds;

  FakeModule(this.binds);
}

class OrdersListBlocMock extends Mock implements OrdersListBloc {}
