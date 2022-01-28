import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kitchen_helper/presenter/screens/orders_list/widgets/order_filter.dart';

import '../../../domain/domain.dart';
import '../../presenter.dart';
import 'orders_list_bloc.dart';
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
    return Scaffold(
      body: BodyWithHeader(
        header: AppBarHeader(
          title: 'Pedidos',
          context: context,
          bottom: OrderFilter(
            onChange: (filter) => _load(filter: filter),
          ),
          action: AppBarHeaderAction(
            label: 'Adicionar',
            icon: Icons.add,
            onPressed: _goToEditScreen,
          ),
        ),
        body: BottomCard(
          child: _buildList(),
        ),
      ),
    );
  }

  Widget _buildList() => ScreenStateBuilder<List<ListingOrderDto>>(
        stateStream: bloc.stream,
        successBuilder: (_, order) {
          if (order.isEmpty) {
            return _buildEmptyState();
          }
          return RefreshIndicator(
            onRefresh: _load,
            child: ListView.builder(
              padding: kSmallEdgeInsets,
              itemCount: order.length,
              itemBuilder: (context, index) => _buildTile(
                context,
                order[index],
              ),
            ),
          );
        },
        errorBuilder: (_, failure) => _buildErrorState(failure.message),
      );

  Widget _buildEmptyState() => Empty(
        text: 'Sem pedidos',
        subtext: 'Adicione pedidos e eles aparecerão aqui',
        action: ElevatedButton(
          onPressed: _goToEditScreen,
          child: const Text('Adicionar pedido'),
        ),
      );

  Widget _buildErrorState(String message) => Empty(
        icon: Icons.error_outline_outlined,
        text: 'Erro',
        subtext: message,
        action: ElevatedButton(
          onPressed: _load,
          child: const Text('Tente novamente'),
        ),
      );

  Widget _buildTile(
    BuildContext context,
    ListingOrderDto order,
  ) =>
      Padding(
        padding: const EdgeInsets.only(bottom: kSmallSpace),
        child: ActionsSlider(
          child: OrderListTile(
            order,
            onTap: () => _goToEditScreen(order),
          ),
          onDelete: () => _tryDelete(context, order),
        ),
      );

  void _tryDelete(BuildContext context, ListingOrderDto order) async {
    final result = await bloc.delete(order.id);
    result.fold((failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(failure.message),
          action: SnackBarAction(
            label: 'Tentar novamente',
            onPressed: () => _tryDelete(context, order),
          ),
        ),
      );
    }, (order) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Pedido excluído'),
          action: SnackBarAction(
            label: 'Desfazer',
            onPressed: () => _trySave(context, order),
          ),
        ),
      );
    });
  }

  void _trySave(BuildContext context, Order order) async {
    final result = await bloc.save(order);
    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            action: SnackBarAction(
              label: 'Tentar novamente',
              onPressed: () => _trySave(context, order),
            ),
          ),
        );
      },
      (_) {},
    );
  }

  Future<void> _load({OrdersFilter? filter}) {
    if (filter != null) {
      lastFilter = filter;
    }
    return bloc.loadOrders(status: lastFilter?.status);
  }

  void _goToEditScreen([ListingOrderDto? order]) async {
    final shouldReload = await EditOrderScreen.navigate(order?.id);
    if (shouldReload ?? false) {
      _load();
    }
  }
}
