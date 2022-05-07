import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:fpdart/fpdart.dart' hide Order, State;

import '../../../../clients/clients.dart';
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
  final _orderDateNotifier = ValueNotifier<DateTime?>(DateTime.now());
  final _deliveryDateNotifier = ValueNotifier<DateTime?>(null);
  final _statusNotifier = ValueNotifier<OrderStatus?>(OrderStatus.ordered);
  final _clientNotifier = ValueNotifier<SelectedClient?>(null);
  final _contactNotifier = ValueNotifier<SelectedContact?>(null);
  final _addressNotifier = ValueNotifier<SelectedAddress?>(null);
  final _products = <EditingOrderProductDto>[];
  final _discounts = <Discount>[];
  List<ContactDomainDto>? _clientContacts;
  List<AddressDomainDto>? _clientAddresses;
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
          Modular.get(),
          Modular.get(),
        );
    _clientNotifier.addListener(() {
      _updateClientContacts();
      _updateClientAddresses();
    });
    if (widget.id != null) {
      bloc.loadOrder(widget.id!).onRightThen((order) {
        _fillControllers(order);
        _fillVariables(order);
        return const Right(null);
      });
    }
  }

  Future<void> _updateClientContacts() async {
    final client = _clientNotifier.value;
    if (client == null) {
      _clientContacts = null;
      if (mounted) {
        setState(() {});
      }
    } else if (client.id == null) {
      _clientContacts = [];
      if (mounted) {
        setState(() {});
      }
    } else {
      final contactsResult = await bloc.findContactsDomain(client.id!);
      contactsResult.fold(
        (l) => _clientContacts = [],
        (contacts) {
          if (contacts.isNotEmpty) {
            final lastContact = contacts.last;
            _contactNotifier.value = SelectedContact(
              id: lastContact.id,
              contact: lastContact.label,
            );
          }
          _clientContacts = contacts;
        },
      );
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _updateClientAddresses() async {
    final client = _clientNotifier.value;
    if (client == null) {
      _clientAddresses = null;
      if (mounted) {
        setState(() {});
      }
    } else if (client.id == null) {
      _clientAddresses = [];
      if (mounted) {
        setState(() {});
      }
    } else {
      final addressesResult = await bloc.findAddressDomain(client.id!);
      addressesResult.fold(
        (l) => _clientAddresses = [],
        (addresses) {
          if (addresses.isNotEmpty) {
            final lastAddress = addresses.last;
            _addressNotifier.value = SelectedAddress(
              id: lastAddress.id,
              identifier: lastAddress.label,
            );
          }
          _clientAddresses = addresses;
        },
      );
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _fillControllers(EditingOrderDto order) {
    _orderDateNotifier.value = order.orderDate;
    _deliveryDateNotifier.value = order.deliveryDate;
    _statusNotifier.value = order.status;
    if (order.clientName != null) {
      _clientNotifier.value =
          SelectedClient(id: order.clientId, name: order.clientName!);
    }
    if (order.clientContact != null) {
      _contactNotifier.value =
          SelectedContact(id: order.contactId, contact: order.clientContact!);
    }
    if (order.clientAddress != null) {
      _addressNotifier.value = SelectedAddress(
          id: order.addressId, identifier: order.clientAddress!);
    }
  }

  void _fillVariables(EditingOrderDto order) async {
    for (final product in order.products) {
      _cost += product.cost;
      _price += product.price;
      _products.add(product);
    }
    _discounts.addAll(order.discounts);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _orderDateNotifier.dispose();
    _deliveryDateNotifier.dispose();
    _statusNotifier.dispose();
    _clientNotifier.dispose();
    _contactNotifier.dispose();
    _addressNotifier.dispose();
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
                    deliveryDateNotifier: _deliveryDateNotifier,
                    orderDateNotifier: _orderDateNotifier,
                    statusNotifier: _statusNotifier,
                    clientNotifier: _clientNotifier,
                    contactNotifier: _contactNotifier,
                    addressNotifier: _addressNotifier,
                    searchContactDomainFn: _clientContacts == null
                        ? null
                        : () async => Right(_clientContacts!),
                    searchAddressDomainFn: _clientAddresses == null
                        ? null
                        : () async => Right(_clientAddresses!),
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
      clientName: _clientNotifier.value?.id == null
          ? _clientNotifier.value?.name
          : null,
      clientId: _clientNotifier.value?.id,
      clientContact: _contactNotifier.value?.id == null
          ? _contactNotifier.value?.contact
          : null,
      contactId: _contactNotifier.value?.id,
      clientAddress: _addressNotifier.value?.id == null
          ? _addressNotifier.value?.identifier
          : null,
      addressId: _addressNotifier.value?.id,
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
