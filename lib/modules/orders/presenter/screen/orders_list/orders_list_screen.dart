import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../../../../common/common.dart';
import '../../../domain/domain.dart';
import '../edit_order/edit_order_screen.dart';
import 'orders_list_bloc.dart';
import 'widgets/orders_filter_display.dart';
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
        OrdersListBloc(
          Modular.get(),
          Modular.get(),
          Modular.get(),
          Modular.get(),
        );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return ListPageTemplate<ListingOrderDto, Order>(
      title: 'Pedidos',
      bloc: bloc,
      tileBuilder: (_, order) => OrderListTile(
        order,
        onTap: () => _goToEditScreen(order),
      ),
      deletedMessage: (order) => 'Pedido de ${order.clientName} excluído',
      emptyText: 'Sem pedidos',
      emptySubtext: 'Adicione pedidos e eles aparecerão aqui',
      emptyActionText: 'Adicionar pedido',
      headerBottom: OrdersFilterDisplay(
        onChange: (newFilter) => _load(filter: newFilter),
      ),
      onAdd: _goToEditScreen,
      onLoad: _load,
    );
  }

  Future<void> _load({OrdersFilter? filter}) {
    if (filter != null) {
      lastFilter = filter;
    }
    return bloc.load(status: lastFilter?.status);
  }

  void _goToEditScreen([ListingOrderDto? order]) async {
    final shouldReload = await EditOrderScreen.navigate(order?.id);
    if (shouldReload ?? false) {
      _load();
    }
  }
}
