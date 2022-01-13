import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:fpdart/fpdart.dart' hide Order, State;

import '../../../domain/domain.dart';
import '../../../extensions.dart';
import '../../presenter.dart';
import '../states.dart';
import 'edit_order_bloc.dart';
import 'models/editing_order_product.dart';
import 'widgets/general_information_form.dart';
import 'widgets/order_products_list.dart';

class EditOrderScreen extends StatefulWidget {
  final Order? initialValue;

  const EditOrderScreen({
    Key? key,
    this.initialValue,
  }) : super(key: key);

  static Future<bool?> navigate([Order? order]) {
    return Modular.to.pushNamed<bool?>('/edit-order', arguments: order);
  }

  @override
  State<EditOrderScreen> createState() => _EditOrderScreenState();
}

class _EditOrderScreenState extends State<EditOrderScreen>
    with SingleTickerProviderStateMixin {
  late final EditOrderBloc bloc;
  late final _tabController = TabController(length: 2, vsync: this);
  final _formKey = GlobalKey<FormState>();
  final _clientNameController = TextEditingController();
  final _clientAddressController = TextEditingController();
  final _orderDateNotifier = ValueNotifier<DateTime?>(DateTime.now());
  final _deliveryDateNotifier = ValueNotifier<DateTime?>(null);
  final _statusNotifier = ValueNotifier<OrderStatus?>(OrderStatus.ordered);
  final _products = <EditingOrderProduct>[];
  var _cost = 0.0;
  var _price = 0.0;

  @override
  void initState() {
    super.initState();
    bloc = EditOrderBloc(Modular.get(), Modular.get(), Modular.get());
    if (widget.initialValue != null) {
      _fillControllers(widget.initialValue!);
      _fillCostPriceAndProducts(widget.initialValue!);
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.initialValue != null ? 'Editar pedido' : 'Novo pedido'),
      ),
      body: Form(
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
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  GeneralInformationForm(
                    clientNameController: _clientNameController,
                    clientAddressController: _clientAddressController,
                    deliveryDateNotifier: _deliveryDateNotifier,
                    orderDateNotifier: _orderDateNotifier,
                    statusNotifier: _statusNotifier,
                    cost: _cost,
                    price: _price,
                  ),
                  OrderProductsList(
                    onAdd: _onAddProduct,
                    onEdit: _onEditProduct,
                    onDelete: _onDeleteProduct,
                    products: _products,
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
      ),
    );
  }

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

  Order _createOrder() {
    return Order(
      id: widget.initialValue?.id,
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
    );
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
