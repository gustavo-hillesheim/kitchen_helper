import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/modules/orders/orders.dart';
import 'package:kitchen_helper/modules/orders/presenter/screen/edit_order/widgets/edit_discount_form.dart';

import '../helpers.dart';

void main() {
  testWidgets(
      'WHEN user inputs data AND press save '
      'SHOULD call onSave with discount', (tester) async {
    Discount? discount;
    await tester.pumpWidget(MaterialApp(
      home: EditDiscountForm(
        onSave: (d) => discount = d,
      ),
    ));

    expectDiscountFormState();
    await inputDiscountInfo(tester, discountOne);

    expect(discount, discountOne);
  });

  testWidgets(
      'WHEN have initialValue AND user inputs data AND press save'
      'SHOULD call onSave with new data', (tester) async {
    Discount discount = discountOne;
    await tester.pumpWidget(MaterialApp(
      home: EditDiscountForm(
        initialValue: discountOne,
        onSave: (d) => discount = d,
      ),
    ));

    expectDiscountFormState(
      reason: discountOne.reason,
      type: discountOne.type,
      value: discountOne.value,
    );
    await inputDiscountInfo(tester, discountTwo);

    expect(discount, discountTwo);
  });

  testWidgets(
      'WHEN user inputs invalid data AND press save'
      'SHOULD not call onSave', (tester) async {
    Discount? discount;
    await tester.pumpWidget(MaterialApp(
      home: EditDiscountForm(
        onSave: (d) => discount = d,
      ),
    ));

    expectDiscountFormState();
    await inputDiscountInfo(
      tester,
      const Discount(
        reason: '',
        type: DiscountType.fixed,
        value: 0,
      ),
    );

    expect(discount, null);
  });
}
