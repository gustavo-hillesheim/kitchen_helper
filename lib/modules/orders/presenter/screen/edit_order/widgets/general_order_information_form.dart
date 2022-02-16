import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/core/core.dart';

import '../../../../../clients/clients.dart';
import '../../../../../../common/common.dart';
import '../../../../../../extensions.dart';
import '../../../../domain/domain.dart';

typedef SearchClientDomainFn = Future<Either<Failure, List<ClientDomainDto>>>
    Function();
typedef SearchContactDomainFn = Future<Either<Failure, List<ContactDomainDto>>>
    Function();
typedef SearchAddressDomainFn = Future<Either<Failure, List<AddressDomainDto>>>
    Function();

class GeneralOrderInformationForm extends StatelessWidget {
  final ValueNotifier<DateTime?> orderDateNotifier;
  final ValueNotifier<DateTime?> deliveryDateNotifier;
  final ValueNotifier<OrderStatus?> statusNotifier;
  final ValueNotifier<SelectedClient?> clientNotifier;
  final ValueNotifier<SelectedContact?> contactNotifier;
  final ValueNotifier<SelectedAddress?> addressNotifier;
  final SearchClientDomainFn searchClientDomainFn;
  final SearchContactDomainFn? searchContactDomainFn;
  final SearchAddressDomainFn? searchAddressDomainFn;
  final double cost;
  final double price;
  final double discount;

  const GeneralOrderInformationForm({
    Key? key,
    required this.orderDateNotifier,
    required this.deliveryDateNotifier,
    required this.statusNotifier,
    required this.cost,
    required this.price,
    required this.discount,
    required this.searchClientDomainFn,
    required this.clientNotifier,
    required this.searchContactDomainFn,
    required this.contactNotifier,
    required this.searchAddressDomainFn,
    required this.addressNotifier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: kMediumEdgeInsets,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: clientNotifier.builder(
                      (_, client, onChange) => SearchTextField<SelectedClient>(
                            name: 'Cliente',
                            value: client,
                            onChanged: onChange,
                            onSearch: _getClients,
                            onFilter: _filterClients,
                            getContentLabel: _getClientContentLabel,
                            getListItemLabel: _getClientListItemLabel,
                          )),
                ),
                kMediumSpacerHorizontal,
                Expanded(
                  child: contactNotifier.builder((_, contact, onChange) =>
                      SearchTextField<SelectedContact>(
                        name: 'Contato',
                        value: contact,
                        onChanged: onChange,
                        enabled: searchContactDomainFn != null,
                        onSearch: _getContacts,
                        onFilter: _filterContacts,
                        getContentLabel: _getContactContentLabel,
                        getListItemLabel: _getContactListItemLabel,
                      )),
                ),
              ],
            ),
            kMediumSpacerVertical,
            addressNotifier.builder(
                (_, address, onChange) => SearchTextField<SelectedAddress>(
                      name: 'Endereço',
                      value: address,
                      onChanged: onChange,
                      enabled: searchContactDomainFn != null,
                      onSearch: _getAddresses,
                      onFilter: _filterAddresses,
                      getContentLabel: _getAddressContentLabel,
                      getListItemLabel: _getAddressListItemLabel,
                    )),
            kMediumSpacerVertical,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: orderDateNotifier.builder(
                    (_, value, onChange) => AppDateTimeField(
                      name: 'Data do pedido',
                      initialValue: value,
                      onChanged: onChange,
                    ),
                  ),
                ),
                kMediumSpacerHorizontal,
                Expanded(
                  child: deliveryDateNotifier.builder(
                    (_, value, onChange) => AppDateTimeField(
                      name: 'Data de entrega',
                      initialValue: value,
                      onChanged: onChange,
                    ),
                  ),
                ),
              ],
            ),
            kMediumSpacerVertical,
            statusNotifier.builder(
              (_, value, onChange) => AppDropdownButtonField(
                name: 'Status',
                values: {
                  OrderStatus.ordered.label: OrderStatus.ordered,
                  OrderStatus.delivered.label: OrderStatus.delivered,
                },
                value: value,
                onChange: onChange,
              ),
            ),
            kMediumSpacerVertical,
            Row(
              children: [
                Expanded(
                  child: CalculatedValue(
                    title: 'Preço',
                    value: price - discount,
                    calculation: [
                      CalculationStep('Preço base', value: price),
                      CalculationStep('Descontos', value: -discount),
                    ],
                  ),
                ),
                kMediumSpacerHorizontal,
                Expanded(
                  child: CalculatedValue(
                    title: 'Lucro',
                    value: price - discount - cost,
                    calculation: [
                      CalculationStep('Preço', value: price - discount),
                      CalculationStep('Custo', value: -cost),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getClientContentLabel(SelectedClient? client) {
    return client?.name ?? '';
  }

  String _getClientListItemLabel(SelectedClient? client) {
    if (client == null) {
      return '';
    }
    if (client.id == null) {
      return 'Novo cliente "${client.name}"';
    }
    return client.name;
  }

  Future<List<SelectedClient>> _getClients(String? search) async {
    final clients = await searchClientDomainFn().throwOnFailure();
    return clients.map((c) => SelectedClient(id: c.id, name: c.label)).toList();
  }

  List<SelectedClient> _filterClients(
      List<SelectedClient> clients, String? search) {
    if (search == null || search.isEmpty) {
      return clients;
    }
    final result = <SelectedClient>[];
    final lowerCaseSearch = search.toLowerCase();
    for (final client in clients) {
      if (client.name.toLowerCase().startsWith(lowerCaseSearch)) {
        result.add(client);
      }
    }
    result.add(SelectedClient(name: search));
    return result;
  }

  String _getContactContentLabel(SelectedContact? contact) {
    return contact?.contact ?? '';
  }

  String _getContactListItemLabel(SelectedContact? contact) {
    if (contact == null) {
      return '';
    }
    if (contact.id == null) {
      return 'Novo contato "${contact.contact}"';
    }
    return contact.contact;
  }

  Future<List<SelectedContact>> _getContacts(String? search) async {
    if (searchContactDomainFn == null) {
      return const [];
    }
    final contacts = await searchContactDomainFn!().throwOnFailure();
    return contacts
        .map((c) => SelectedContact(id: c.id, contact: c.label))
        .toList();
  }

  List<SelectedContact> _filterContacts(
      List<SelectedContact> contacts, String? search) {
    if (search == null || search.isEmpty) {
      return contacts;
    }
    final result = <SelectedContact>[];
    final lowerCaseSearch = search.toLowerCase();
    for (final contact in contacts) {
      if (contact.contact.toLowerCase().startsWith(lowerCaseSearch)) {
        result.add(contact);
      }
    }
    result.add(SelectedContact(contact: search));
    return result;
  }

  String _getAddressContentLabel(SelectedAddress? address) {
    return address?.identifier ?? '';
  }

  String _getAddressListItemLabel(SelectedAddress? address) {
    if (address == null) {
      return '';
    }
    if (address.id == null) {
      return 'Novo endereço "${address.identifier}"';
    }
    return address.identifier;
  }

  Future<List<SelectedAddress>> _getAddresses(String? search) async {
    if (searchContactDomainFn == null) {
      return const [];
    }
    final addresses = await searchAddressDomainFn!().throwOnFailure();
    return addresses
        .map((c) => SelectedAddress(id: c.id, identifier: c.label))
        .toList();
  }

  List<SelectedAddress> _filterAddresses(
      List<SelectedAddress> addresses, String? search) {
    if (search == null || search.isEmpty) {
      return addresses;
    }
    final result = <SelectedAddress>[];
    final lowerCaseSearch = search.toLowerCase();
    for (final address in addresses) {
      if (address.identifier.toLowerCase().startsWith(lowerCaseSearch)) {
        result.add(address);
      }
    }
    result.add(SelectedAddress(identifier: search));
    return result;
  }
}

class SelectedClient extends Equatable {
  final int? id;
  final String name;

  const SelectedClient({this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

class SelectedContact extends Equatable {
  final int? id;
  final String contact;

  const SelectedContact({this.id, required this.contact});

  @override
  List<Object?> get props => [id, contact];
}

class SelectedAddress extends Equatable {
  final int? id;
  final String identifier;

  const SelectedAddress({this.id, required this.identifier});

  @override
  List<Object?> get props => [id, identifier];
}
