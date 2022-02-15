import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:fpdart/fpdart.dart' hide Order, State;

import '../../../../../common/common.dart';
import '../../../../../core/core.dart';
import '../../../../../extensions.dart';
import '../../../domain/domain.dart';
import 'edit_order_bloc.dart';
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
  final _clientContactController = TextEditingController();
  final _clientAddressController = TextEditingController();
  final _orderDateNotifier = ValueNotifier<DateTime?>(DateTime.now());
  final _deliveryDateNotifier = ValueNotifier<DateTime?>(null);
  final _statusNotifier = ValueNotifier<OrderStatus?>(OrderStatus.ordered);
  final _products = <EditingOrderProductDto>[];
  final _discounts = <Discount>[];
  var _cost = 0.0;
  var _price = 0.0;
  String? _clientName;
  int? _clientId;
  int? _contactId;
  int? _addressId;

  @override
  void initState() {
    super.initState();
    bloc = widget.bloc ??
        EditOrderBloc(
          Modular.get(),
          Modular.get(),
          Modular.get(),
          Modular.get(),
          Modular.get(),
        );
    if (widget.id != null) {
      bloc.loadOrder(widget.id!).onRightThen((order) {
        _fillControllers(order);
        _fillVariables(order);
        return const Right(null);
      });
    }
  }

  void _fillControllers(EditingOrderDto order) {
    _clientContactController.text = order.clientContact ?? '';
    _clientAddressController.text = order.clientAddress ?? '';
    _orderDateNotifier.value = order.orderDate;
    _deliveryDateNotifier.value = order.deliveryDate;
    _statusNotifier.value = order.status;
  }

  void _fillVariables(EditingOrderDto order) async {
    setState(() {
      for (final product in order.products) {
        _cost += product.cost;
        _price += product.price;
        _products.add(product);
      }
      _discounts.addAll(order.discounts);
      _clientId = order.clientId;
      _contactId = order.contactId;
      _addressId = order.addressId;
    });
  }

  @override
  void dispose() {
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
                _buildFailureState(state.failure)
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
                    clientContactController: _clientContactController,
                    clientAddressController: _clientAddressController,
                    deliveryDateNotifier: _deliveryDateNotifier,
                    orderDateNotifier: _orderDateNotifier,
                    statusNotifier: _statusNotifier,
                    searchClientDomainFn: bloc.findClientDomain,
                    onSelectClient: (client) => setState(() {
                      _clientId = client?.id;
                      _clientName = client?.name;
                    }),
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
      final state = await bloc.save(_createEditingOrderDto());
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

  EditingOrderDto _createEditingOrderDto() {
    return EditingOrderDto(
      id: widget.id,
      clientName: _clientName,
      clientId: _clientId,
      clientContact: _clientContactController.text,
      contactId: _contactId,
      clientAddress: _clientAddressController.text,
      addressId: _addressId,
      deliveryDate: _deliveryDateNotifier.value!,
      orderDate: _orderDateNotifier.value!,
      status: _statusNotifier.value!,
      products: _products,
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

  void _onEditProduct(EditingOrderProductDto oldValue, OrderProduct newValue) {
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

  void _onDeleteProduct(EditingOrderProductDto product) {
    setState(() {
      _products.remove(product);
      _cost -= product.cost;
      _price -= product.price;
    });
  }
}
