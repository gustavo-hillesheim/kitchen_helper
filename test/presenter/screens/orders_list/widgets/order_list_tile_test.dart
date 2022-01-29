import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/domain/domain.dart';
import 'package:kitchen_helper/presenter/presenter.dart';
import 'package:kitchen_helper/presenter/screens/orders_list/widgets/order_list_tile.dart';
import 'package:kitchen_helper/presenter/screens/orders_list/widgets/order_list_tile_bloc.dart';
import 'package:kitchen_helper/presenter/screens/states.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../mocks.dart';
import '../../../finders.dart';

void main() {
  late OrderListTileBloc bloc;
  late StreamController<ScreenState<List<ListingOrderProductDto>>>
      streamController;
  late ScreenState<List<ListingOrderProductDto>> state;

  void setState(ScreenState<List<ListingOrderProductDto>> newState) {
    state = newState;
    streamController.sink.add(newState);
  }

  setUp(() {
    state = const EmptyState();
    bloc = OrderListTileBlocMock();
    streamController = StreamController();
    when(() => bloc.stream).thenAnswer((_) => streamController.stream);
    when(() => bloc.state).thenAnswer((_) => state);
  });

  testWidgets('SHOULD render order data', (tester) async {
    when(() => bloc.loadProducts(batmanOrder.id!)).thenAnswer((_) async {
      setState(const LoadingState());
      await Future.delayed(const Duration(seconds: 1));
      setState(SuccessState(_listingOrderProducts(batmanOrder.products)));
    });

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
          body: OrderListTile(
        listingBatmanOrderDto,
        onTap: () {},
        bloc: bloc,
      )),
    ));
    // Renders price
    await tester.pump();

    expect(find.text(batmanOrder.clientName), findsOneWidget);
    expect(find.text(batmanOrder.clientAddress), findsOneWidget);
    expect(find.text(Formatter.completeDate(batmanOrder.deliveryDate)),
        findsOneWidget);
    expect(find.text(Formatter.currency(50)), findsOneWidget);
    expect(TagFinder(label: 'Entregue'), findsOneWidget);

    // Expands Expandable
    await tester.tap(find.byIcon(Icons.expand_more));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    for (final orderProduct in batmanOrder.products) {
      final product = recipesMap[orderProduct.id]!;
      expect(
        find.text(
          '- ${Formatter.simpleNumber(orderProduct.quantity)}'
          '${product.measurementUnit.abbreviation}'
          ' de ${product.name}',
        ),
        findsOneWidget,
      );
    }
  });

  testWidgets('WHEN bloc returns Failure SHOULD render failure',
      (tester) async {
    when(() => bloc.loadProducts(listingSpidermanOrderDto.id))
        .thenAnswer((_) async {
      setState(const LoadingState());
      await Future.delayed(const Duration(seconds: 1));
      setState(const FailureState(FakeFailure('failure')));
    });

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
          body: OrderListTile(
        listingSpidermanOrderDto,
        onTap: () {},
        bloc: bloc,
      )),
    ));
    // Renders price
    await tester.pump();

    expect(find.text(Formatter.currency(25)), findsOneWidget);
    expect(TagFinder(label: 'Entregue'), findsNothing);

    // Expands Expandable
    await tester.tap(find.byIcon(Icons.expand_more));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.text('Erro ao obter produtos: failure'), findsOneWidget);
  });
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

class OrderListTileBlocMock extends Mock implements OrderListTileBloc {}
