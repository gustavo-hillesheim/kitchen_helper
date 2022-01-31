import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../../../../../../presenter/presenter.dart';
import '../../../../domain/domain.dart';
import 'edit_discount_form.dart';

typedef OnEditDiscount = void Function(Discount, Discount);
typedef OnAddDiscount = ValueChanged<Discount>;
typedef OnDeleteDiscount = ValueChanged<Discount>;

class DiscountList extends StatelessWidget {
  final List<Discount> discounts;
  final OnAddDiscount onAdd;
  final OnEditDiscount onEdit;
  final OnDeleteDiscount onDelete;

  const DiscountList({
    Key? key,
    required this.discounts,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListView.builder(
          padding: kMediumEdgeInsets.copyWith(bottom: kSmallSpace),
          shrinkWrap: true,
          itemCount: discounts.length,
          itemBuilder: (_, i) {
            final discount = discounts[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: kSmallSpace),
              child: ActionsSlider(
                onDelete: () => onDelete(discount),
                child: DiscountListTile(
                  discount,
                  onTap: () => showDiscountForm(context, discount),
                ),
              ),
            );
          },
        ),
        Center(
          child: SecondaryButton(
            child: const Text('Adicionar desconto'),
            onPressed: () => showDiscountForm(context),
          ),
        ),
      ],
    );
  }

  void showDiscountForm(BuildContext context, [Discount? initialValue]) {
    showDialog(
      context: context,
      builder: (_) {
        return EditDiscountForm(
          initialValue: initialValue,
          onSave: (discount) {
            if (initialValue != null) {
              onEdit(initialValue, discount);
            } else {
              onAdd(discount);
            }
            Navigator.of(context).pop();
          },
        );
      },
    );
  }
}

class DiscountListTile extends StatelessWidget {
  final Discount discount;
  final VoidCallback onTap;

  const DiscountListTile(
    this.discount, {
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final reasonStyle = textTheme.headline6!.copyWith(
      fontWeight: FontWeight.w400,
    );
    final valueStyle = textTheme.headline5!.copyWith(
      fontWeight: FontWeight.w300,
    );

    return FlatTile(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: AutoSizeText(
              discount.reason,
              style: reasonStyle,
              minFontSize: reasonStyle.fontSize!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          kMediumSpacerHorizontal,
          if (discount.type == DiscountType.fixed)
            Text(Formatter.currency(discount.value), style: valueStyle)
          else
            Text(
              '${Formatter.simpleNumber(discount.value)}%',
              style: valueStyle,
            )
        ],
      ),
    );
  }
}
