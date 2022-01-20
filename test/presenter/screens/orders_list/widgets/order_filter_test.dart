import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/domain/domain.dart';
import 'package:kitchen_helper/presenter/screens/orders_list/widgets/order_filter.dart';

import '../../../finders.dart';

void main() {
  testWidgets('WHEN change filter SHOULD call onChange', (tester) async {
    OrdersFilter? filter;
    const foregroundColor = Colors.red;
    const backgroundColor = Colors.blue;

    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: foregroundColor),
        scaffoldBackgroundColor: backgroundColor,
      ),
      home: Scaffold(
        body: OrderFilter(onChange: (newFilter) => filter = newFilter),
      ),
    ));

    final inactiveOrderedFinder =
        ToggleableTagFinder(label: 'Não Entregue', value: false);
    final activeOrderedFinder =
        ToggleableTagFinder(label: 'Não Entregue', value: true);
    final inactiveDeliveredFinder =
        ToggleableTagFinder(label: 'Entregue', value: false);
    final activeDeliveredFinder =
        ToggleableTagFinder(label: 'Entregue', value: true);
    expect(inactiveOrderedFinder, findsOneWidget);
    expect(inactiveDeliveredFinder, findsOneWidget);

    await tester.tap(inactiveOrderedFinder);
    await tester.pump();

    expect(activeOrderedFinder, findsOneWidget);
    expect(inactiveDeliveredFinder, findsOneWidget);
    expect(filter, const OrdersFilter(status: OrderStatus.ordered));

    await tester.tap(inactiveDeliveredFinder);
    await tester.pump();

    expect(inactiveOrderedFinder, findsOneWidget);
    expect(activeDeliveredFinder, findsOneWidget);
    expect(filter, const OrdersFilter(status: OrderStatus.delivered));
  });
}
