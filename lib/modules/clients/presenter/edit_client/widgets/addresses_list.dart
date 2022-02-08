import 'package:flutter/material.dart';
import 'package:kitchen_helper/extensions.dart';
import 'package:kitchen_helper/common/common.dart';
import 'package:kitchen_helper/modules/clients/clients.dart';
import 'package:kitchen_helper/modules/clients/domain/model/states.dart';

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
  final _formKey = GlobalKey<FormState>();
  final _cepController = TextEditingController();
  final _cityController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _complementController = TextEditingController();
  final _identifierController = TextEditingController();
  final _stateNotifier = ValueNotifier<States?>(null);

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      final address = widget.initialValue!;
      if (address.cep != null) {
        _cepController.text = Formatter.simpleNumber(address.cep!);
      }
      if (address.number != null) {
        _numberController.text = Formatter.simpleNumber(address.number!);
      }
      _stateNotifier.value = address.state;
      _cityController.text = address.city ?? '';
      _neighborhoodController.text = address.neighborhood ?? '';
      _streetController.text = address.street ?? '';
      _complementController.text = address.complement ?? '';
      _identifierController.text = address.identifier;
    }
  }

  @override
  void dispose() {
    _cepController.dispose();
    _stateNotifier.dispose();
    _cityController.dispose();
    _neighborhoodController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _complementController.dispose();
    _identifierController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: kMediumEdgeInsets,
      child: Center(
        child: Material(
          child: Padding(
            padding: kMediumEdgeInsets,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.initialValue != null
                        ? 'Editar endereço'
                        : 'Adicionar endereço',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  kMediumSpacerVertical,
                  Row(
                    children: [
                      Expanded(
                        child: AppTextFormField.number(
                          name: 'CEP',
                          controller: _cepController,
                          required: false,
                        ),
                      ),
                      kSmallSpacerHorizontal,
                      Expanded(
                        child: _stateNotifier.builder((_, value, onChange) =>
                            AppDropdownButtonField<States>(
                              name: 'Estado',
                              value: value,
                              onChange: onChange,
                              values: States.values.asNameMap(),
                              required: false,
                            )),
                      ),
                    ],
                  ),
                  kSmallSpacerVertical,
                  Row(
                    children: [
                      Expanded(
                        child: AppTextFormField(
                          name: 'Cidade',
                          controller: _cityController,
                          required: false,
                        ),
                      ),
                      kSmallSpacerHorizontal,
                      Expanded(
                        child: AppTextFormField(
                          name: 'Bairro',
                          controller: _neighborhoodController,
                          required: false,
                        ),
                      ),
                    ],
                  ),
                  kSmallSpacerVertical,
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: AppTextFormField(
                          name: 'Rua',
                          controller: _streetController,
                          required: false,
                        ),
                      ),
                      kSmallSpacerHorizontal,
                      Expanded(
                        child: AppTextFormField.number(
                          name: 'Número',
                          controller: _numberController,
                          required: false,
                        ),
                      ),
                    ],
                  ),
                  kSmallSpacerVertical,
                  AppTextFormField(
                    name: 'Complemento',
                    controller: _complementController,
                    required: false,
                  ),
                  kSmallSpacerVertical,
                  AppTextFormField(
                    name: 'Identificador',
                    controller: _identifierController,
                  ),
                  kMediumSpacerVertical,
                  PrimaryButton(
                    child: const Text('Salvar'),
                    onPressed: _save,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      final address = Address(
        identifier: _identifierController.text,
        cep: int.tryParse(_cepController.text),
        city: _cityController.text,
        complement: _complementController.text,
        number: int.tryParse(_numberController.text),
        neighborhood: _neighborhoodController.text,
        state: _stateNotifier.value,
        street: _streetController.text,
      );
      widget.onSave(address);
    }
  }
}
