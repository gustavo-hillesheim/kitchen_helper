import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:fpdart/fpdart.dart' hide Order, State;

import '../../../../../common/common.dart';
import '../../../../../core/core.dart';
import '../../../../../extensions.dart';
import '../../../domain/domain.dart';
import 'edit_order_bloc.dart';
import 'models/editing_order_product.dart';
import 'widgets/discount_list.dart';
import 'widgets/general_order_information_form.dart';
import 'widgets/order_products_list.dart';

class EditOrderScreen extends StatefulWidget {
  final int? id;
  final EditOrderBloc? bloc;

  const EditOrderScreen({
    Key? key,
    this.id,
    this.bloc,
  }) : super(key: key);

  static Future<bool?> navigate([int? id]) {
    return Modular.to.pushNamed<bool?>('./edit', arguments: id);
  }

  @override
  State<EditOrderScreen> createState() => _EditOrderScreenState();
}

class _EditOrderScreenState extends State<EditOrderScreen>
    with SingleTickerProviderStateMixin {
  late final EditOrderBloc bloc;
  late final _tabController = TabController(length: 3, vsync: this);
  final _formKey = GlobalKey<FormState>();
  final _clientNameController = TextEditingController();
  final _clientContactController = TextEditingController();
  final _clientAddressController = TextEditingController();
  final _orderDateNotifier = ValueNotifier<DateTime?>(DateTime.now());
  final _deliveryDateNotifier = ValueNotifier<DateTime?>(null);
  final _statusNotifier = ValueNotifier<OrderStatus?>(OrderStatus.ordered);
  final _products = <EditingOrderProduct>[];
  final _discounts = <Discount>[];
  var _cost = 0.0;
  var _price = 0.0;

  @override
  void initState() {
    super.initState();
    bloc = widget.bloc ??
        EditOrderBloc(
          Modular.get(),
          Modular.get(),
          Modular.get(),
          Modular.get(),
        );
    if (widget.id != null) {
      bloc.stream
          .where((state) => state is SuccessState<Order>)
          .map((state) => (state as SuccessState<Order>).value)
          .listen((order) {
        _fillControllers(order);
        _fillCostPriceAndProducts(order);
        _discounts.addAll(order.discounts);
      });
      bloc.loadOrder(widget.id!);
    }
  }

  void _fillControllers(Order order) {
    _clientNameController.text = order.clientName;
    _clientAddressController.text = order.clientAddress;
    _orderDateNotifier.value = order.orderDate;
    _deliveryDateNotifier.value = order.deliveryDate;
    _statusNotifier.value = order.status;
  }

  void _fillCostPriceAndProducts(Order order) async {
    final result = await bloc.getEditingOrderProducts(order.products);
    result.fold(
      (failure) => debugPrint(
        'Could not find products: ${failure.message}',
      ),
      (products) {
        if (mounted) {
          setState(() {
            for (final product in products) {
              _cost += product.cost;
              _price += product.price;
              _products.add(product);
            }
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _clientContactController.dispose();
    _clientAddressController.dispose();
    _orderDateNotifier.dispose();
    _deliveryDateNotifier.dispose();
    _statusNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.id != null ? 'Editar pedido' : 'Novo pedido'),
      ),
      body: StreamBuilder(
        stream: bloc.stream,
        builder: (context, snapshot) {
          final state = bloc.state;
          return Stack(
            children: [
              if (state is FailureState)
                _buildFailureState((state as FailureState).failure)
              else if (state is LoadingOrderState)
                const Center(child: CircularProgressIndicator())
              else
                _buildForm(),
              if (state is LoadingState) _buildLoadingOverlay(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFailureState(Failure failure) => Center(
        child: Text(failure.message, style: const TextStyle(color: Colors.red)),
      );

  Widget _buildLoadingOverlay() => Positioned.fill(
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );

  Widget _buildForm() => Form(
        key: _formKey,
        child: Column(
          children: [
            TabBar(
              padding: const EdgeInsets.symmetric(horizontal: kMediumSpace),
              controller: _tabController,
              labelColor: Colors.black87,
              unselectedLabelColor: Colors.black45,
              tabs: const [
                Tab(text: 'Geral'),
                Tab(text: 'Produtos'),
                Tab(text: 'Descontos'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  GeneralOrderInformationForm(
                    clientNameController: _clientNameController,
                    clientContactController: _clientContactController,
                    clientAddressController: _clientAddressController,
                    deliveryDateNotifier: _deliveryDateNotifier,
                    orderDateNotifier: _orderDateNotifier,
                    statusNotifier: _statusNotifier,
                    cost: _cost,
                    price: _price,
                    discount: _calculateDiscount(),
                  ),
                  OrderProductsList(
                    onAdd: _onAddProduct,
                    onEdit: _onEditProduct,
                    onDelete: _onDeleteProduct,
                    products: _products,
                  ),
                  DiscountList(
                    discounts: _discounts,
                    onDelete: _onDeleteDiscount,
                    onEdit: _onEditDiscount,
                    onAdd: _onAddDiscount,
                  ),
                ],
              ),
            ),
            Padding(
              padding: kMediumEdgeInsets,
              child: PrimaryButton(
                child: const Text('Salvar'),
                onPressed: _save,
              ),
            ),
          ],
        ),
      );

  void _save() async {
    if (_formKey.currentState?.validate() ?? false) {
      final order = _createOrder();
      final state = await bloc.save(order);
      if (state is SuccessState) {
        Modular.to.pop(true);
      } else if (state is FailureState) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.failure.message)),
        );
      }
    }
  }

  double _calculateDiscount() {
    var totalDiscount = 0.0;
    for (final discount in _discounts) {
      totalDiscount += discount.calculate(_price);
    }
    return totalDiscount;
  }

  Order _createOrder() {
    return Order(
      id: widget.id,
      clientName: _clientNameController.text,
      clientAddress: _clientAddressController.text,
      deliveryDate: _deliveryDateNotifier.value!,
      orderDate: _orderDateNotifier.value!,
      status: _statusNotifier.value!,
      products: _products
          .map((ep) => OrderProduct(
                id: ep.id,
                quantity: ep.quantity,
              ))
          .toList(),
      discounts: _discounts,
    );
  }

  void _onAddDiscount(Discount discount) {
    setState(() {
      _discounts.add(discount);
    });
  }

  void _onEditDiscount(Discount oldValue, Discount newValue) {
    setState(() {
      final index = _discounts.indexOf(oldValue);
      _discounts[index] = newValue;
    });
  }

  void _onDeleteDiscount(Discount discount) {
    setState(() {
      _discounts.remove(discount);
    });
  }

  void _onAddProduct(OrderProduct product) {
    bloc.getEditingOrderProduct(product).onRightThen((editingOrderProduct) {
      setState(() {
        _products.add(editingOrderProduct);
        _cost += editingOrderProduct.cost;
        _price += editingOrderProduct.price;
      });
      return const Right(null);
    });
  }

  void _onEditProduct(EditingOrderProduct oldValue, OrderProduct newValue) {
    bloc.getEditingOrderProduct(newValue).onRightThen((editingOrderProduct) {
      final index = _products.indexOf(oldValue);
      setState(() {
        _products[index] = editingOrderProduct;
        _cost = _cost - oldValue.cost + editingOrderProduct.cost;
        _price = _price - oldValue.price + editingOrderProduct.price;
      });
      return const Right(null);
    });
  }

  void _onDeleteProduct(EditingOrderProduct product) {
    setState(() {
      _products.remove(product);
      _cost -= product.cost;
      _price -= product.price;
    });
  }
}
