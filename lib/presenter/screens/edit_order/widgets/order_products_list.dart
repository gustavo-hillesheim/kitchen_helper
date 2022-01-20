import 'package:flutter/material.dart';

import '../../../../domain/domain.dart';
import '../../../presenter.dart';
import '../models/editing_order_product.dart';
import 'edit_order_product_form.dart';

typedef OnEditProduct = void Function(EditingOrderProduct, OrderProduct);
typedef OnAddProduct = ValueChanged<OrderProduct>;
typedef OnDeletProduct = ValueChanged<EditingOrderProduct>;

class OrderProductsList extends StatelessWidget {
  final OnAddProduct onAdd;
  final OnEditProduct onEdit;
  final OnDeletProduct onDelete;
  final List<EditingOrderProduct> products;

  const OrderProductsList({
    Key? key,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    required this.products,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListView.builder(
          padding: kMediumEdgeInsets.copyWith(bottom: kSmallSpace),
          shrinkWrap: true,
          itemCount: products.length,
          itemBuilder: (_, i) {
            final product = products[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: kSmallSpace),
              child: ActionsSlider(
                onDelete: () => onDelete(product),
                child: OrderProductListTile(
                  product,
                  onTap: () => showOrderProductForm(context, product),
                ),
              ),
            );
          },
        ),
        Center(
          child: SecondaryButton(
            child: const Text('Adicionar produto'),
            onPressed: () => showOrderProductForm(context),
          ),
        ),
      ],
    );
  }

  void showOrderProductForm(
    BuildContext context, [
    EditingOrderProduct? initialValue,
  ]) {
    showDialog(
      context: context,
      builder: (_) {
        return EditOrderProductForm(
          initialValue: initialValue,
          onSave: (orderProduct) {
            if (initialValue != null) {
              onEdit(initialValue, orderProduct);
            } else {
              onAdd(orderProduct);
            }
            Navigator.of(context).pop();
          },
        );
      },
    );
  }
}

class OrderProductListTile extends StatelessWidget {
  final EditingOrderProduct product;
  final VoidCallback onTap;

  const OrderProductListTile(
    this.product, {
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final nameText = Text(
      product.name,
      style: textTheme.headline6!.copyWith(
        fontWeight: FontWeight.w400,
      ),
    );
    final priceText = Text(
      Formatter.currency(product.price),
      style: textTheme.headline5!.copyWith(
        fontWeight: FontWeight.w300,
      ),
    );
    final quantityText = Text(
      '${Formatter.simpleNumber(product.quantity)} '
      '${product.measurementUnit.abbreviation}',
      style: textTheme.subtitle2,
    );
    final productInfo = Row(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            nameText,
            kSmallSpacerVertical,
            quantityText,
          ],
        ),
        const Spacer(),
        priceText,
      ],
    );

    return FlatTile(
      child: productInfo,
      onTap: onTap,
    );
  }
}
