import 'package:flutter/material.dart';

import '../../../../../../common/common.dart';
import '../../../../domain/domain.dart';

class OrdersFilterDisplay extends StatefulWidget {
  final ValueChanged<OrdersFilter> onChange;

  const OrdersFilterDisplay({
    Key? key,
    required this.onChange,
  }) : super(key: key);

  @override
  _OrdersFilterDisplayState createState() => _OrdersFilterDisplayState();
}

class _OrdersFilterDisplayState extends State<OrdersFilterDisplay> {
  OrderStatus? _filterStatus;

  @override
  Widget build(BuildContext context) {
    return FilterWithTags(
      tags: [
        ToggleableTag(
          label: 'Não Entregue',
          value: _filterStatus == OrderStatus.ordered,
          onChange: (value) =>
              _updateFilterStatus(value ? OrderStatus.ordered : null),
        ),
        ToggleableTag(
          label: 'Entregue',
          value: _filterStatus == OrderStatus.delivered,
          onChange: (value) =>
              _updateFilterStatus(value ? OrderStatus.delivered : null),
        ),
      ],
    );
  }

  void _updateFilterStatus(OrderStatus? status) {
    setState(() {
      _filterStatus = status;
      widget.onChange(OrdersFilter(
        status: _filterStatus,
      ));
    });
  }
}
