import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/core/core.dart';

import '../../../../../clients/clients.dart';
import '../../../../../../common/common.dart';
import '../../../../../../extensions.dart';
import '../../../../domain/domain.dart';

typedef SearchClientDomainFn = Future<Either<Failure, List<ClientDomainDto>>>
    Function();

class GeneralOrderInformationForm extends StatelessWidget {
  final TextEditingController clientContactController;
  final TextEditingController clientAddressController;
  final ValueNotifier<DateTime?> orderDateNotifier;
  final ValueNotifier<DateTime?> deliveryDateNotifier;
  final ValueNotifier<OrderStatus?> statusNotifier;
  final ValueChanged<SelectedClient?> onSelectClient;
  final SearchClientDomainFn searchClientDomainFn;
  final double cost;
  final double price;
  final double discount;

  const GeneralOrderInformationForm({
    Key? key,
    required this.clientContactController,
    required this.clientAddressController,
    required this.orderDateNotifier,
    required this.deliveryDateNotifier,
    required this.statusNotifier,
    required this.cost,
    required this.price,
    required this.discount,
    required this.searchClientDomainFn,
    required this.onSelectClient,
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
                  child: SearchTextField<SelectedClient>(
                    name: 'Cliente',
                    onChanged: onSelectClient,
                    onSearch: _getClients,
                    getLabelFromValue: (client) => client?.name ?? '',
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

  Future<List<SelectedClient>> _getClients(String? search) async {
    print(search);
    final clients = await searchClientDomainFn().throwOnFailure();
    return clients.map((c) => SelectedClient(id: c.id, name: c.label)).toList();
  }
}

class SelectedClient {
  final int? id;
  final String name;

  const SelectedClient({required this.id, required this.name});
}
