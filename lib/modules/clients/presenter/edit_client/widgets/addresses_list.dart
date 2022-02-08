import 'package:flutter/material.dart';
import 'package:kitchen_helper/common/common.dart';
import 'package:kitchen_helper/modules/clients/clients.dart';

typedef OnAddAddress = ValueChanged<Address>;
typedef OnEditAddress = void Function(Address oldValue, Address newValue);
typedef OnDeleteAddress = ValueChanged<Address>;

class AddressesList extends StatelessWidget {
  final OnAddAddress onAdd;
  final OnEditAddress onEdit;
  final OnDeleteAddress onDelete;
  final List<Address> addresses;

  const AddressesList(
    this.addresses, {
    Key? key,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: kMediumEdgeInsets.copyWith(top: 0, bottom: 0),
      title: const Text('Endereços'),
      children: [
        for (final address in addresses)
          ActionsSlider(
            onDelete: () => onDelete(address),
            child: AddressListTile(
              address,
              onTap: () => showAddressForm(context, address),
            ),
          ),
        Center(
          child: Padding(
            padding: kSmallEdgeInsets,
            child: SecondaryButton(
              child: const Text('Adicionar endereço'),
              onPressed: () => showAddressForm(context),
            ),
          ),
        ),
      ],
    );
  }

  void showAddressForm(BuildContext context, [Address? initialValue]) {
    showDialog(
      context: context,
      builder: (_) {
        return EditAddressForm(
          initialValue: initialValue,
          onSave: (address) {
            if (initialValue != null) {
              onEdit(initialValue, address);
            } else {
              onAdd(address);
            }
            Navigator.of(context).pop();
          },
        );
      },
    );
  }
}

class AddressListTile extends StatelessWidget {
  final Address address;
  final VoidCallback onTap;

  const AddressListTile(
    this.address, {
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(address.identifier),
      onTap: onTap,
    );
  }
}

class EditAddressForm extends StatefulWidget {
  final Address? initialValue;
  final ValueChanged<Address> onSave;

  const EditAddressForm({
    Key? key,
    required this.initialValue,
    required this.onSave,
  }) : super(key: key);

  @override
  _EditAddressFormState createState() => _EditAddressFormState();
}

class _EditAddressFormState extends State<EditAddressForm> {
  @override
  Widget build(BuildContext context) {
    return Text('Edit address form');
  }
}
