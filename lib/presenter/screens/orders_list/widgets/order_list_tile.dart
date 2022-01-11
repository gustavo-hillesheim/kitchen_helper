import 'package:flutter/material.dart';

import '../../../../domain/domain.dart';
import '../../../presenter.dart';
import '../../states.dart';
import 'order_list_tile_bloc.dart';

typedef OrderListTileState = ScreenState<List<OrderProductData>>;

class OrderListTile extends StatefulWidget {
  final Order order;

  const OrderListTile(this.order, {Key? key}) : super(key: key);

  @override
  State<OrderListTile> createState() => _OrderListTileState();
}

class _OrderListTileState extends State<OrderListTile> {
  late final OrderListTileBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = OrderListTileBloc();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return StreamBuilder<OrderListTileState>(
        stream: bloc.stream,
        builder: (context, snapshot) {
          final isLoading = bloc.state is LoadingState;
          return Stack(
            children: [
              Opacity(
                opacity: isLoading ? 0.5 : 1,
                child: FlatTile(
                  onTap: () {},
                  padding: FlatTile.defaultPadding.copyWith(
                    right: kSmallSpace,
                    // Aligns the Expandable button with the title
                    top: kSmallSpace,
                  ),
                  child: Expandable(
                    top: buildTopSection(textTheme),
                    flexibleBuilder: (_) => buildFlexibleSection(
                      bloc.state,
                      textTheme,
                    ),
                    bottom: buildBottomSection(),
                  ),
                ),
              ),
              if (isLoading)
                const Positioned.fill(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          );
        });
  }

  Widget buildTopSection(TextTheme textTheme) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // keeps the FlatTile top padding equal to the default one
          SizedBox(height: FlatTile.defaultPadding.top - kSmallSpace),
          Row(
            children: [
              Text(
                widget.order.clientName,
                style: textTheme.headline6?.copyWith(
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(),
              Text(
                Formatter.currency(50),
                style: textTheme.headline6?.copyWith(
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
          kExtraSmallSpacerVertical,
          Text(widget.order.clientAddress),
        ],
      );

  Widget buildFlexibleSection(OrderListTileState state, TextTheme textTheme) {
    if (state is EmptyState) {
      bloc.loadProducts();
    }
    if (state is EmptyState || state is LoadingState) {
      return const SizedBox.shrink();
    }
    if (state is FailureState) {
      final failureState = state as FailureState;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: kExtraSmallSpace),
        child: Text(
          'Erro ao obter produtos: ${failureState.failure.message}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
    final products = (state as SuccessState<List<OrderProductData>>).value;
    if (products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: kExtraSmallSpace),
        child: Text('O pedido não possui nenhum produto'),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        kExtraSmallSpacerVertical,
        for (final product in products) ...[
          Text(
            '- ${Formatter.simpleNumber(product.quantity)}'
            '${product.measurementUnit.abbreviation} '
            'de ${product.name}',
            style: TextStyle(
              color: textTheme.subtitle2?.color,
            ),
          ),
          kExtraSmallSpacerVertical,
        ],
      ],
    );
  }

  Widget buildBottomSection() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(Formatter.completeDate(widget.order.deliveryDate)),
          kSmallSpacerVertical,
          Row(
            children: [
              if (widget.order.status == OrderStatus.delivered)
                const Tag(label: 'Entregue', color: Colors.green),
            ],
          ),
        ],
      );
}
