import 'package:flutter/material.dart';

import '../../../../../../presenter/presenter.dart';
import '../../../../domain/domain.dart';

class OrderFilter extends StatefulWidget {
  final ValueChanged<OrdersFilter> onChange;

  const OrderFilter({
    Key? key,
    required this.onChange,
  }) : super(key: key);

  @override
  _OrderFilterState createState() => _OrderFilterState();
}

class _OrderFilterState extends State<OrderFilter> {
  OrderStatus? _filterStatus;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const IconButton(
          onPressed: null,
          icon: Icon(Icons.filter_alt_outlined),
        ),
        ToggleableTag(
          label: 'Não Entregue',
          value: _filterStatus == OrderStatus.ordered,
          onChange: (value) =>
              _updateFilterStatus(value ? OrderStatus.ordered : null),
        ),
        kSmallSpacerHorizontal,
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
