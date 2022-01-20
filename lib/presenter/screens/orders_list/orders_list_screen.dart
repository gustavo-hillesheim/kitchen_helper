import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../../domain/domain.dart';
import '../../presenter.dart';
import 'orders_list_bloc.dart';
import 'widgets/order_filter.dart';
import 'widgets/order_list_tile.dart';

class OrdersListScreen extends StatefulWidget {
  final OrdersListBloc? bloc;

  const OrdersListScreen({Key? key, this.bloc}) : super(key: key);

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  late final OrdersListBloc bloc;
  OrdersFilter? lastFilter;

  @override
  void initState() {
    super.initState();
    bloc = widget.bloc ??
        OrdersListBloc(Modular.get(), Modular.get(), Modular.get());
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
      headerBottom: OrderFilter(
        onChange: (filter) {
          lastFilter = filter;
          bloc.load(status: filter.status);
        },
      ),
    );
  }

  void _goToEditScreen([Order? order]) async {
    final shouldReload = await EditOrderScreen.navigate(order);
    if (shouldReload ?? false) {
      bloc.load(status: lastFilter?.status);
    }
  }
}
