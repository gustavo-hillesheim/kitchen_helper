import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kitchen_helper/common/common.dart';
import 'package:kitchen_helper/core/core.dart';
import 'package:kitchen_helper/modules/clients/clients.dart';
import 'package:kitchen_helper/modules/clients/presenter/edit_client/widgets/addresses_list.dart';
import 'package:kitchen_helper/modules/clients/presenter/edit_client/widgets/contacts_list.dart';

import 'edit_client_bloc.dart';

class EditClientScreen extends StatefulWidget {
  final int? id;

  const EditClientScreen({Key? key, this.id}) : super(key: key);

  static Future<bool?> navigate([int? id]) {
    return Modular.to.pushNamed<bool?>('./edit', arguments: id);
  }

  @override
  _EditClientScreenState createState() => _EditClientScreenState();
}

class _EditClientScreenState extends State<EditClientScreen> {
  final _formKey = GlobalKey<FormState>();
  List<Contact> _contacts = [];
  List<Address> _addresses = [];
  late EditClientBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = EditClientBloc(Modular.get(), Modular.get());
    if (widget.id != null) {
      bloc.stream
          .where((state) => state is SuccessState<Client>)
          .map((state) => (state as SuccessState<Client>).value)
          .listen(_setControllersValues);
      bloc.loadClient(widget.id!);
    }
  }

  void _setControllersValues(Client client) {
    _contacts = client.contacts;
    _addresses = client.addresses;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.id != null ? 'Editar cliente' : 'Novo cliente'),
      ),
      body: StreamBuilder(
        stream: bloc.stream,
        builder: (context, snapshot) {
          final state = bloc.state;
          return Stack(
            children: [
              if (state is FailureState)
                _buildFailureState((state as FailureState).failure)
              else if (state is LoadingClientState)
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
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: kMediumEdgeInsets,
                    child: AppTextFormField(name: 'Nome'),
                  ),
                  ContactsList(
                    _contacts,
                    onAdd: _onAddContact,
                    onEdit: _onEditContact,
                    onDelete: _onDeleteContact,
                  ),
                  AddressesList(
                    _addresses,
                    onAdd: _onAddAddress,
                    onEdit: _onEditAddress,
                    onDelete: _onDeleteAddress,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: kMediumEdgeInsets,
            child: PrimaryButton(
              onPressed: _save,
              child: const Text('Salvar'),
            ),
          ),
        ],
      ));

  void _save() {}

  void _onAddContact(Contact contact) {
    setState(() {
      _contacts.add(contact);
    });
  }

  void _onEditContact(Contact oldValue, Contact newValue) {
    setState(() {
      final index = _contacts.indexOf(oldValue);
      _contacts[index] = newValue;
    });
  }

  void _onDeleteContact(Contact contact) {
    setState(() {
      final index = _contacts.indexOf(contact);
      _contacts.removeAt(index);
    });
  }

  void _onAddAddress(Address address) {
    setState(() {
      _addresses.add(address);
    });
  }

  void _onEditAddress(Address oldValue, Address newValue) {
    setState(() {
      final index = _addresses.indexOf(oldValue);
      _addresses[index] = newValue;
    });
  }

  void _onDeleteAddress(Address address) {
    setState(() {
      final index = _addresses.indexOf(address);
      _addresses.removeAt(index);
    });
  }
}
