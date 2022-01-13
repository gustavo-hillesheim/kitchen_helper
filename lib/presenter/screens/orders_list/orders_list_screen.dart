import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../../domain/domain.dart';
import '../../presenter.dart';
import 'orders_list_bloc.dart';
import 'widgets/order_list_tile.dart';

class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({Key? key}) : super(key: key);

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  late final OrdersListBloc bloc;
  OrderStatus? _filterStatus;

  @override
  void initState() {
    super.initState();
    bloc = OrdersListBloc(Modular.get(), Modular.get(), Modular.get());
    bloc.load();
  }

  @override
  Widget build(BuildContext context) {
    return ListPageTemplate<Order>(
      title: 'Pedidos',
      bloc: bloc,
      tileBuilder: (_, order) => OrderListTile(
        order,
        onTap: () => _goToEditScreen(order),
      ),
      deletedMessage: (order) => 'Pedido excluído',
      emptyText: 'Sem pedidos',
      emptySubtext: 'Adicione pedidos e eles aparecerão aqui',
      emptyActionText: 'Adicionar pedido',
      onAdd: () => _goToEditScreen(),
      headerBottom: Row(
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
      ),
    );
  }

  void _updateFilterStatus(OrderStatus? status) {
    setState(() {
      _filterStatus = status;
      print(_filterStatus);
      bloc.load(status: _filterStatus);
    });
  }

  void _goToEditScreen([Order? order]) async {
    final shouldReload = await EditOrderScreen.navigate(order);
    if (shouldReload ?? false) {
      bloc.load();
    }
  }
}
