import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
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
  late StreamController<ScreenState<List<OrderProductData>>> streamController;

  setUp(() {
    bloc = OrderListTileBlocMock();
    streamController = StreamController();
    when(() => bloc.stream).thenAnswer((_) {
      streamController.sink.add(const EmptyState());
      return streamController.stream;
    });
  });

  testWidgets('SHOULD render order data', (tester) async {
    when(() => bloc.getPrice(batmanOrder))
        .thenAnswer((_) async => const Right(1));
    when(() => bloc.loadProducts(batmanOrder)).thenAnswer((_) async {
      streamController.sink.add(const LoadingState());
      await Future.delayed(const Duration(seconds: 1));
      streamController.sink
          .add(SuccessState(_productData(batmanOrder.products)));
    });

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
          body: OrderListTile(
        batmanOrder,
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
    expect(find.text(Formatter.currency(1)), findsOneWidget);
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
    when(() => bloc.getPrice(spidermanOrder))
        .thenAnswer((_) async => const Left(FakeFailure('price failure')));
    when(() => bloc.loadProducts(spidermanOrder)).thenAnswer((_) async {
      streamController.sink.add(const LoadingState());
      await Future.delayed(const Duration(seconds: 1));
      streamController.sink.add(const FailureState(FakeFailure('failure')));
    });

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
          body: OrderListTile(spidermanOrder, onTap: () {}, bloc: bloc)),
    ));
    // Renders price
    await tester.pump();
    expect(find.text(Formatter.currency(1)), findsNothing);
    expect(TagFinder(label: 'Entregue'), findsNothing);

    // Expands Expandable
    await tester.tap(find.byIcon(Icons.expand_more));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.text('Erro ao obter produtos: failure'), findsOneWidget);
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

class OrderListTileBlocMock extends Mock implements OrderListTileBloc {}
