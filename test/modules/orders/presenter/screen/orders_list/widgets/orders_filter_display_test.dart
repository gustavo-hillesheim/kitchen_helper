import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/modules/orders/orders.dart';
import 'package:kitchen_helper/modules/orders/presenter/screen/orders_list/widgets/orders_filter_display.dart';

import '../../../../../../finders.dart';

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
        body: OrdersFilterDisplay(
          onChange: (newFilter) => filter = newFilter?.toOrdersFilter(),
        ),
      ),
    ));

    final inactiveOrderedFinder =
        ToggleableTagFinder(label: 'Não Entregue', isActive: false);
    final activeOrderedFinder =
        ToggleableTagFinder(label: 'Não Entregue', isActive: true);
    final inactiveDeliveredFinder =
        ToggleableTagFinder(label: 'Entregue', isActive: false);
    final activeDeliveredFinder =
        ToggleableTagFinder(label: 'Entregue', isActive: true);
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
