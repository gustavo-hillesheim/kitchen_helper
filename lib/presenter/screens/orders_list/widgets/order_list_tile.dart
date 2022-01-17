import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../../../domain/domain.dart';
import '../../../presenter.dart';
import '../../states.dart';
import 'order_list_tile_bloc.dart';

typedef OrderListTileState = ScreenState<List<OrderProductData>>;

class OrderListTile extends StatefulWidget {
  final Order order;
  final VoidCallback onTap;
  final OrderListTileBloc? bloc;

  const OrderListTile(
    this.order, {
    Key? key,
    required this.onTap,
    this.bloc,
  }) : super(key: key);

  @override
  State<OrderListTile> createState() => _OrderListTileState();
}

class _OrderListTileState extends State<OrderListTile> {
  late final OrderListTileBloc bloc;
  double? _price;

  @override
  void initState() {
    super.initState();
    bloc = widget.bloc ?? OrderListTileBloc(Modular.get(), Modular.get());
    bloc.getPrice(widget.order).then((result) {
      result.fold(
        (failure) => debugPrint('Could not get order price ${failure.message}'),
        (price) => setState(() {
          _price = price;
        }),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return StreamBuilder<OrderListTileState>(
        stream: bloc.stream,
        builder: (context, snapshot) {
          final isLoading = snapshot.data is LoadingState;
          return Stack(
            children: [
              Opacity(
                opacity: isLoading ? 0.5 : 1,
                child: FlatTile(
                  onTap: widget.onTap,
                  padding: FlatTile.defaultPadding.copyWith(
                    right: kSmallSpace,
                    // Aligns the Expandable button with the title
                    top: kSmallSpace,
                  ),
                  child: Expandable(
                    top: buildTopSection(textTheme),
                    flexibleBuilder: (_) => buildFlexibleSection(
                      snapshot.data!,
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
              if (_price != null)
                Text(
                  Formatter.currency(_price!),
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
      bloc.loadProducts(widget.order);
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
