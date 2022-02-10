import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../../../../extensions.dart';
import '../../../../../common/common.dart';
import '../../../clients.dart';
import 'edit_address_form_bloc.dart';

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
  late EditAddressFormBloc bloc;
  final _formKey = GlobalKey<FormState>();
  final _cepController = TextEditingController();
  final _cityController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _complementController = TextEditingController();
  final _identifierController = TextEditingController();
  final _stateNotifier = ValueNotifier<States?>(null);
  bool _isUpdatingIdentifierAutomatically = false;
  bool _userUpdatedIdentifier = false;

  @override
  void initState() {
    super.initState();
    bloc = EditAddressFormBloc(Modular.get());
    if (widget.initialValue != null) {
      _fillControllers(widget.initialValue!);
    }
    _streetController.addListener(_updateIdentifier);
    _numberController.addListener(_updateIdentifier);
    _complementController.addListener(_updateIdentifier);
    _identifierController.addListener(_onUpdateIdentifier);
    _cepController.addListener(_searchAddressData);
  }

  void _fillControllers(Address address) {
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
    // When the address is saved we can't know is the user updated the identifier,
    // so it's better to assume they did
    _userUpdatedIdentifier = true;
  }

  void _updateIdentifier() {
    if (_userUpdatedIdentifier) {
      return;
    }
    final street = _streetController.text;
    final number = _numberController.text;
    final complement = _complementController.text;
    var identifier = street;
    if (number.isNotEmpty) {
      identifier += ', $number';
    }
    if (complement.isNotEmpty) {
      identifier += ' ($complement)';
    }
    _isUpdatingIdentifierAutomatically = true;
    _identifierController.text = identifier;
    _isUpdatingIdentifierAutomatically = false;
  }

  void _onUpdateIdentifier() {
    if (_isUpdatingIdentifierAutomatically) {
      return;
    }
    _userUpdatedIdentifier = true;
  }

  void _searchAddressData() async {
    final cepStr = _cepController.text;
    if (cepStr.length < 8) {
      return;
    }
    final cep = int.parse(cepStr);
    final result = await bloc.loadAddressData(cep);
    result.fold((l) => null, (addressData) {
      _streetController.text = addressData.street;
      _complementController.text = addressData.complement;
      _cityController.text = addressData.city;
      _neighborhoodController.text = addressData.neighborhood;
      _stateNotifier.value = addressData.state;
    });
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
            child: StreamBuilder(
                initialData: bloc.state,
                stream: bloc.stream,
                builder: (_, snapshot) {
                  final state = snapshot.data;
                  return Stack(
                    children: [
                      _buildForm(),
                      if (state is LoadingState) _buildLoadingOverlay()
                    ],
                  );
                }),
          ),
        ),
      ),
    );
  }

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
                    maxLength: 8,
                    required: false,
                  ),
                ),
                kSmallSpacerHorizontal,
                Expanded(
                  child: _stateNotifier.builder(
                      (_, value, onChange) => AppDropdownButtonField<States>(
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
      );

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
