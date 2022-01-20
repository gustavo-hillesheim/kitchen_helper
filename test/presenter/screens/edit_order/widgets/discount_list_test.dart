import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/domain/domain.dart';
import 'package:kitchen_helper/presenter/screens/edit_order/widgets/discount_list.dart';

import '../helpers.dart';

void main() {
  testWidgets('SHOULD render discounts', (tester) async {
    final discounts = [discountOne, discountTwo];
    await pumpWidget(tester, discounts);

    expect(find.byType(DiscountListTile), findsNWidgets(2));
    for (final discount in discounts) {
      expectDiscountListTile(discount);
    }
    expect(find.text('Adicionar desconto'), findsOneWidget);
  });

  testWidgets('WHEN user deletes discount SHOULD call onDelete',
      (tester) async {
    final discounts = [discountOne];
    await pumpWidget(tester, discounts);
    expect(find.byType(DiscountListTile), findsNWidgets(1));

    // Deletes
    await tester.drag(
        find.byType(DiscountListTile).first, const Offset(-1000, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pump();

    await pumpWidget(tester, discounts);
    expect(discounts.length, 0);
    expect(find.byType(DiscountListTile), findsNothing);
  });

  testWidgets('WHEN user adds discount SHOULD call onAdd', (tester) async {
    final discounts = <Discount>[];
    await pumpWidget(tester, discounts);
    expect(find.byType(DiscountListTile), findsNothing);

    await tester.tap(find.text('Adicionar desconto'));
    await tester.pumpAndSettle();

    await inputDiscountInfo(tester, discountOne);
    expect(discounts.length, 1);
    expect(discounts[0], discountOne);
  });

  testWidgets('WHEN used edits discount SHOULD call onEdit', (tester) async {
    final discounts = [discountOne];
    await pumpWidget(tester, discounts);
    expect(find.byType(DiscountListTile), findsOneWidget);

    await tester.tap(find.byType(DiscountListTile));
    await tester.pumpAndSettle();

    expectDiscountFormState(
      reason: discountOne.reason,
      type: discountOne.type,
      value: discountOne.value,
    );
    await inputDiscountInfo(tester, discountTwo);
    expect(discounts.length, 1);
    expect(discounts[0], discountTwo);
  });
}

Future<void> pumpWidget(WidgetTester tester, List<Discount> discounts) async {
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: DiscountList(
        discounts: discounts,
        onAdd: (d) => discounts.add(d),
        onEdit: (od, nd) {
          final index = discounts.indexOf(od);
          discounts[index] = nd;
        },
        onDelete: (d) => discounts.remove(d),
      ),
    ),
  ));
}
