import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/modules/orders/presenter/edit_order/models/editing_order_product.dart';
import 'package:kitchen_helper/modules/orders/presenter/edit_order/widgets/order_products_list.dart';

import '../../../../../mocks.dart';
import '../helpers.dart';

void main() {
  setUp(() {
    mockRecipeIngredientsSelectorService();
  });

  testWidgets('WHEN has OrderProducts SHOULD render', (tester) async {
    final products = editingOrderProducts(
      [cakeOrderProduct, iceCreamOrderProduct],
    );
    await tester.pumpWidget(MaterialApp(
      home: OrderProductsList(
        products: products,
        onAdd: (_) {},
        onEdit: (_, __) {},
        onDelete: (_) {},
      ),
    ));

    expect(find.byType(OrderProductListTile), findsNWidgets(2));
    for (final product in products) {
      expectOrderProductListTile(product);
    }
    expect(find.text('Adicionar produto'), findsOneWidget);
  });

  testWidgets('WHEN user deletes product SHOULD call onDelete', (tester) async {
    final products = editingOrderProducts(
      [cakeOrderProduct],
    );
    await pumpWidget(tester, products);
    expect(find.byType(OrderProductListTile), findsNWidgets(1));

    await delete(tester, find.byType(OrderProductListTile).first);

    await pumpWidget(tester, products);
    expect(products.length, 0);
    expect(find.byType(OrderProductListTile), findsNothing);
  });

  testWidgets('WHEN user adds product SHOULD call onAdd', (tester) async {
    final products = <EditingOrderProduct>[];
    await pumpWidget(tester, products);
    expect(find.byType(OrderProductListTile), findsNothing);

    await tester.tap(find.text('Adicionar produto'));
    await tester.pumpAndSettle();

    await inputOrderProductInfo(
      tester,
      cakeRecipe.name,
      cakeOrderProduct.quantity,
      measurementUnit: cakeRecipe.measurementUnit,
    );
    expect(products.length, 1);
    expect(
      products[0],
      EditingOrderProduct(
        name: cakeRecipe.name,
        quantity: cakeOrderProduct.quantity,
        measurementUnit: cakeRecipe.measurementUnit,
        cost: cakeRecipe.id!.toDouble(),
        id: cakeRecipe.id!,
        price: cakeRecipe.id!.toDouble(),
      ),
    );
  });

  testWidgets('WHEN used edits product SHOULD call onEdit', (tester) async {
    final products = editingOrderProducts(
      [iceCreamOrderProduct],
    );
    await pumpWidget(tester, products);
    expect(find.byType(OrderProductListTile), findsOneWidget);

    await tester.tap(find.byType(OrderProductListTile));
    await tester.pumpAndSettle();

    expectOrderProductFormState(
      name: iceCreamRecipe.name,
      quantity: iceCreamOrderProduct.quantity,
      measurementUnit: iceCreamRecipe.measurementUnit,
    );
    await inputOrderProductInfo(
      tester,
      cakeRecipe.name,
      cakeOrderProduct.quantity,
      measurementUnit: cakeRecipe.measurementUnit,
    );
    expect(products.length, 1);
    expect(
      products[0],
      EditingOrderProduct(
        name: cakeRecipe.name,
        quantity: cakeOrderProduct.quantity,
        measurementUnit: cakeRecipe.measurementUnit,
        cost: cakeRecipe.id!.toDouble(),
        id: cakeRecipe.id!,
        price: cakeRecipe.id!.toDouble(),
      ),
    );
  });
}

Future<void> pumpWidget(
    WidgetTester tester, List<EditingOrderProduct> products) async {
  await tester.pumpWidget(MaterialApp(
    home: OrderProductsList(
      products: products,
      onAdd: (p) => products.add(editingOrderProduct(p)),
      onEdit: (op, np) {
        final index = products.indexOf(op);
        products[index] = editingOrderProduct(np);
      },
      onDelete: (p) => products.remove(p),
    ),
  ));
}
