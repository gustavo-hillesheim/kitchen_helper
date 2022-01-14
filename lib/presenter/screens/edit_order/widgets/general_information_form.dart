import 'package:flutter/material.dart';

import '../../../../domain/domain.dart';
import '../../../../extensions.dart';
import '../../../presenter.dart';

class GeneralInformationForm extends StatelessWidget {
  final TextEditingController clientNameController;
  final TextEditingController clientAddressController;
  final ValueNotifier<DateTime?> orderDateNotifier;
  final ValueNotifier<DateTime?> deliveryDateNotifier;
  final ValueNotifier<OrderStatus?> statusNotifier;
  final double cost;
  final double price;
  final double discount;

  const GeneralInformationForm({
    Key? key,
    required this.clientNameController,
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
            AppTextFormField(
              name: 'Cliente',
              controller: clientNameController,
            ),
            kMediumSpacerVertical,
            AppTextFormField(
              name: 'Endereço',
              controller: clientAddressController,
              multiline: true,
            ),
            kMediumSpacerVertical,
            orderDateNotifier.builder(
              (_, value, onChange) => AppDateTimeField(
                name: 'Data do pedido',
                initialValue: value,
                onChanged: onChange,
              ),
            ),
            kMediumSpacerVertical,
            deliveryDateNotifier.builder(
              (_, value, onChange) => AppDateTimeField(
                name: 'Data de entrega',
                initialValue: value,
                onChanged: onChange,
              ),
            ),
            kMediumSpacerVertical,
            statusNotifier.builder(
              (_, value, onChange) => AppDropdownButtonField(
                name: 'Status',
                values: const {
                  'Recebido': OrderStatus.ordered,
                  'Entregue': OrderStatus.delivered,
                },
                value: value,
                onChange: onChange,
              ),
            ),
            kMediumSpacerVertical,
            Text('Custo: ${Formatter.currency(cost)}'),
            kSmallSpacerVertical,
            Text('Preço: ${Formatter.currency(price)}'),
            kSmallSpacerVertical,
            Text('Desconto: ${Formatter.currency(discount)}'),
            kSmallSpacerVertical,
            Text('Preço Final: ${Formatter.currency(price - discount)}'),
            kSmallSpacerVertical,
            Text('Lucro: ${Formatter.currency(price - discount - cost)}'),
          ],
        ),
      ),
    );
  }
}
