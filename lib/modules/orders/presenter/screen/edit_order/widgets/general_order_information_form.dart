import 'package:flutter/material.dart';

import '../../../../../../common/common.dart';
import '../../../../../../extensions.dart';
import '../../../../domain/domain.dart';

class GeneralOrderInformationForm extends StatelessWidget {
  final TextEditingController clientNameController;
  final TextEditingController clientContactController;
  final TextEditingController clientAddressController;
  final ValueNotifier<DateTime?> orderDateNotifier;
  final ValueNotifier<DateTime?> deliveryDateNotifier;
  final ValueNotifier<OrderStatus?> statusNotifier;
  final double cost;
  final double price;
  final double discount;

  const GeneralOrderInformationForm({
    Key? key,
    required this.clientNameController,
    required this.clientContactController,
    required this.clientAddressController,
    required this.orderDateNotifier,
    required this.deliveryDateNotifier,
    required this.statusNotifier,
    required this.cost,
    required this.price,
    required this.discount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: kMediumEdgeInsets,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppTextFormField(
                    name: 'Cliente',
                    controller: clientNameController,
                  ),
                ),
                kMediumSpacerHorizontal,
                Expanded(
                  child: AppTextFormField(
                    name: 'Contato',
                    controller: clientContactController,
                  ),
                ),
              ],
            ),
            kMediumSpacerVertical,
            AppTextFormField(
              name: 'Endereço',
              controller: clientAddressController,
            ),
            kMediumSpacerVertical,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: orderDateNotifier.builder(
                    (_, value, onChange) => AppDateTimeField(
                      name: 'Data do pedido',
                      initialValue: value,
                      onChanged: onChange,
                    ),
                  ),
                ),
                kMediumSpacerHorizontal,
                Expanded(
                  child: deliveryDateNotifier.builder(
                    (_, value, onChange) => AppDateTimeField(
                      name: 'Data de entrega',
                      initialValue: value,
                      onChanged: onChange,
                    ),
                  ),
                ),
              ],
            ),
            kMediumSpacerVertical,
            statusNotifier.builder(
              (_, value, onChange) => AppDropdownButtonField(
                name: 'Status',
                values: {
                  OrderStatus.ordered.label: OrderStatus.ordered,
                  OrderStatus.delivered.label: OrderStatus.delivered,
                },
                value: value,
                onChange: onChange,
              ),
            ),
            kMediumSpacerVertical,
            Row(
              children: [
                Expanded(
                  child: CalculatedValue(
                    title: 'Preço',
                    value: price - discount,
                    calculation: [
                      CalculationStep('Preço base', value: price),
                      CalculationStep('Descontos', value: -discount),
                    ],
                  ),
                ),
                kMediumSpacerHorizontal,
                Expanded(
                  child: CalculatedValue(
                    title: 'Lucro',
                    value: price - discount - cost,
                    calculation: [
                      CalculationStep('Preço', value: price - discount),
                      CalculationStep('Custo', value: -cost),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
