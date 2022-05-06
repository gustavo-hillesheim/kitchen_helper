import 'package:flutter/material.dart';
import 'package:kitchen_helper/common/common.dart';

import '../model/editing_clients_filter.dart';

class ClientsFilterDisplay extends StatefulWidget {
  final ValueChanged<EditingClientsFilter?> onChange;

  const ClientsFilterDisplay({
    Key? key,
    required this.onChange,
  }) : super(key: key);

  @override
  State<ClientsFilterDisplay> createState() => _ClientsFilterDisplayState();
}

class _ClientsFilterDisplayState extends State<ClientsFilterDisplay> {
  EditingClientsFilter? _filter;

  @override
  Widget build(BuildContext context) {
    return FilterWithTags(
      onOpenFilter: _showFilterForm,
      tags: [
        if (_filter?.name != null)
          ToggleableTag(
            label: 'Nome contém: ${_filter!.name}',
            isActive: true,
            onChange: (_) => _removeNameFilter(),
          ),
      ],
    );
  }

  void _removeNameFilter() {
    const newFilter = EditingClientsFilter(name: null);
    _updateFilter(newFilter);
  }

  void _updateFilter(EditingClientsFilter? filter) {
    setState(() {
      _filter = filter;
      widget.onChange(_filter);
    });
  }

  void _showFilterForm() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: _ClientsFilterForm(
          initialValue: _filter,
          onFilter: (newFilter) {
            _updateFilter(newFilter);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}

class _ClientsFilterForm extends StatefulWidget {
  final EditingClientsFilter? initialValue;
  final ValueChanged<EditingClientsFilter> onFilter;

  const _ClientsFilterForm({
    Key? key,
    required this.initialValue,
    required this.onFilter,
  }) : super(key: key);

  @override
  State<_ClientsFilterForm> createState() => __ClientsFilterFormState();
}

class __ClientsFilterFormState extends State<_ClientsFilterForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final initialValue = widget.initialValue;
    if (initialValue != null) {
      _nameController.text = initialValue.name ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: kMediumEdgeInsets,
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(
              'Filtrar pedidos',
              style: Theme.of(context).textTheme.headline6,
            ),
            kMediumSpacerVertical,
            AppTextFormField(
              name: 'Nome',
              controller: _nameController,
              required: false,
            ),
            kMediumSpacerVertical,
            PrimaryButton(
              child: const Text('Filtrar'),
              onPressed: _onFilter,
            ),
          ],
        ),
      ),
    );
  }

  void _onFilter() {
    if (_formKey.currentState?.validate() ?? false) {
      final name = _nameController.text.trim();
      final filter = EditingClientsFilter(
        name: name.isNotEmpty ? name : null,
      );
      widget.onFilter(filter);
    }
  }
}
