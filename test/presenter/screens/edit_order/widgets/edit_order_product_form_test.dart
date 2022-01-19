import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/domain/domain.dart';
import 'package:kitchen_helper/presenter/screens/edit_order/widgets/edit_order_product_form.dart';

import '../../../../mocks.dart';
import '../helpers.dart';

void main() {
  setUp(() {
    mockRecipeIngredientsSelectorService();
  });

  testWidgets('WHEN inputs info AND taps save SHOULD call onSave',
      (tester) async {
    OrderProduct? orderProduct;
    await tester.pumpWidget(MaterialApp(
      home: EditOrderProductForm(
        onSave: (o) => orderProduct = o,
      ),
    ));

    expect(find.text('Adicionar produto'), findsOneWidget);
    expectOrderProductFormState();
    await inputOrderProductInfo(
      tester,
      cakeRecipe.name,
      10,
      measurementUnit: cakeRecipe.measurementUnit,
    );
    expect(orderProduct, OrderProduct(id: cakeRecipe.id!, quantity: 10));
  });

  testWidgets(
      'WHEN changes initial info AND taps save SHOULD call onSave '
      'with new info', (tester) async {
    OrderProduct? orderProduct;
    await tester.pumpWidget(MaterialApp(
      home: EditOrderProductForm(
        initialValue: editingOrderProduct(iceCreamOrderProduct),
        onSave: (o) => orderProduct = o,
      ),
    ));

    expect(find.text('Editar produto'), findsOneWidget);
    expectOrderProductFormState(
      name: iceCreamRecipe.name,
      measurementUnit: iceCreamRecipe.measurementUnit,
      quantity: iceCreamOrderProduct.quantity,
    );
    await inputOrderProductInfo(
      tester,
      cakeRecipe.name,
      10,
      measurementUnit: cakeRecipe.measurementUnit,
    );
    expect(orderProduct, OrderProduct(id: cakeRecipe.id!, quantity: 10));
  });

  testWidgets('WHEN inputs invalid info AND taps save SHOULD not call onSave',
      (tester) async {
    OrderProduct? orderProduct;
    await tester.pumpWidget(MaterialApp(
      home: EditOrderProductForm(
        onSave: (o) => orderProduct = o,
      ),
    ));

    expect(find.text('Adicionar produto'), findsOneWidget);
    expectOrderProductFormState();
    await inputOrderProductInfo(tester, null, 10);
    expect(orderProduct, null);
  });
}
