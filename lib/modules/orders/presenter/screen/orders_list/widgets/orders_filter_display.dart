import 'package:flutter/material.dart';
import 'package:kitchen_helper/extensions.dart';

import '../../../../../../common/common.dart';
import '../../../../domain/domain.dart';

class OrdersFilterDisplay extends StatefulWidget {
  final ValueChanged<OrdersFilter?> onChange;

  const OrdersFilterDisplay({
    Key? key,
    required this.onChange,
  }) : super(key: key);

  @override
  _OrdersFilterDisplayState createState() => _OrdersFilterDisplayState();
}

class _OrdersFilterDisplayState extends State<OrdersFilterDisplay> {
  OrdersFilter? _filter;

  @override
  Widget build(BuildContext context) {
    return FilterWithTags(
      onOpenFilter: _showFilterForm,
      tags: [
        ToggleableTag(
          label: 'Não Entregue',
          isActive: _filter?.status == OrderStatus.ordered,
          onChange: (value) =>
              _updateFilterStatus(value ? OrderStatus.ordered : null),
        ),
        ToggleableTag(
          label: 'Entregue',
          isActive: _filter?.status == OrderStatus.delivered,
          onChange: (value) =>
              _updateFilterStatus(value ? OrderStatus.delivered : null),
        ),
      ],
    );
  }

  void _updateFilterStatus(OrderStatus? status) {
    final filter = OrdersFilter(
      clientId: _filter?.clientId,
      deliveryDateStart: _filter?.deliveryDateStart,
      deliveryDateEnd: _filter?.deliveryDateEnd,
      orderDateStart: _filter?.orderDateStart,
      orderDateEnd: _filter?.orderDateEnd,
      status: status,
    );
    _updateFilter(filter);
  }

  void _updateFilter(OrdersFilter? filter) {
    setState(() {
      _filter = filter;
      widget.onChange(_filter);
    });
  }

  void _showFilterForm() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: _OrdersFilterForm(
          initialValue: _filter,
          onFilter: (newFilter) {
            _updateFilter(newFilter);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}

class _OrdersFilterForm extends StatefulWidget {
  final OrdersFilter? initialValue;
  final ValueChanged<OrdersFilter> onFilter;

  const _OrdersFilterForm({
    Key? key,
    required this.initialValue,
    required this.onFilter,
  }) : super(key: key);

  @override
  State<_OrdersFilterForm> createState() => __OrdersFilterFormState();
}

class __OrdersFilterFormState extends State<_OrdersFilterForm> {
  final _formKey = GlobalKey<FormState>();
  final _clientIdNotifier = ValueNotifier<SelectedClient?>(null);
  final _orderDateStartNotifier = ValueNotifier<DateTime?>(null);
  final _orderDateEndNotifier = ValueNotifier<DateTime?>(null);
  final _deliveryDateStartNotifier = ValueNotifier<DateTime?>(null);
  final _deliveryDateEndNotifier = ValueNotifier<DateTime?>(null);
  final _statusNotifier = ValueNotifier<OrderStatus?>(null);

  @override
  void initState() {
    super.initState();
    final initialValue = widget.initialValue;
    if (initialValue != null) {
      _orderDateStartNotifier.value = initialValue.orderDateStart;
      _orderDateEndNotifier.value = initialValue.orderDateEnd;
      _deliveryDateStartNotifier.value = initialValue.deliveryDateStart;
      _deliveryDateEndNotifier.value = initialValue.deliveryDateEnd;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: kMediumEdgeInsets,
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(
              'Filtrar pedidos',
              style: Theme.of(context).textTheme.headline6,
            ),
            kMediumSpacerVertical,
            _clientIdNotifier.builder(
              (_, client, onChange) => ClientSelector(
                value: client,
                onChange: onChange,
                required: false,
              ),
            ),
            kSmallSpacerVertical,
            _orderDateStartNotifier.builder(
              (_, orderDateStart, onChange) => AppDateTimeField(
                name: 'Início do período de pedido',
                initialValue: orderDateStart,
                onChanged: onChange,
                required: false,
              ),
            ),
            kSmallSpacerVertical,
            _orderDateEndNotifier.builder(
              (_, orderDateEnd, onChange) => AppDateTimeField(
                name: 'Fim do período de pedido',
                initialValue: orderDateEnd,
                onChanged: onChange,
                required: false,
              ),
            ),
            kSmallSpacerVertical,
            _deliveryDateStartNotifier.builder(
              (_, deliveryDateStart, onChange) => AppDateTimeField(
                name: 'Início do período de entrega',
                initialValue: deliveryDateStart,
                onChanged: onChange,
                required: false,
              ),
            ),
            kSmallSpacerVertical,
            _deliveryDateEndNotifier.builder(
              (_, deliveryDateEnd, onChange) => AppDateTimeField(
                name: 'Fim do período de entrega',
                initialValue: deliveryDateEnd,
                onChanged: onChange,
                required: false,
              ),
            ),
            kSmallSpacerVertical,
            _statusNotifier.builder(
              (_, status, onChange) => AppDropdownButtonField<OrderStatus?>(
                name: 'Status',
                value: status,
                onChange: onChange,
                required: false,
                values: {
                  'Sem filtro': null,
                  for (final o in OrderStatus.values) o.label: o
                },
              ),
            ),
            kMediumSpacerVertical,
            PrimaryButton(
              child: const Text('Filtrar'),
              onPressed: _onFilter,
            ),
          ],
        ),
      ),
    );
  }

  void _onFilter() {
    if (_formKey.currentState?.validate() ?? false) {
      final filter = OrdersFilter(
        clientId: _clientIdNotifier.value?.id,
        deliveryDateEnd: _deliveryDateEndNotifier.value,
        deliveryDateStart: _deliveryDateStartNotifier.value,
        orderDateEnd: _orderDateEndNotifier.value,
        orderDateStart: _orderDateStartNotifier.value,
      );
      widget.onFilter(filter);
    }
  }
}
