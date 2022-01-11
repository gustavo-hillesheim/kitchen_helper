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
      tileBuilder: (_, order) => OrderListTile(order),
      deletedMessage: (order) => 'Pedido excluído',
      emptyText: 'Sem pedidos',
      emptySubtext: 'Adicione pedidos e eles aparecerão aqui',
      emptyActionText: 'Adicionar pedido',
      onAdd: () {},
      headerBottom: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const IconButton(
            onPressed: null,
            icon: Icon(Icons.filter_alt_outlined),
          ),
          ToggleableTag(
            label: 'Entregue',
            onChange: (value) => bloc.load(isDelivered: value),
          ),
        ],
      ),
    );
  }
}
