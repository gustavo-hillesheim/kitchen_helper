import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../extensions.dart';
import 'search_text_field.dart';
import 'client_selector_service.dart';

class ClientSelector extends StatefulWidget {
  final SelectedClient? value;
  final ValueChanged<SelectedClient?> onChange;
  final bool required;

  const ClientSelector({
    Key? key,
    required this.onChange,
    this.value,
    this.required = true,
  }) : super(key: key);

  @override
  State<ClientSelector> createState() => _ClientSelectorState();
}

class _ClientSelectorState extends State<ClientSelector> {
  late final service = Modular.get<ClientSelectorService>();

  @override
  Widget build(BuildContext context) {
    return SearchTextField<SelectedClient>(
      name: 'Cliente',
      value: widget.value,
      onChanged: widget.onChange,
      required: widget.required,
      onSearch: _getClients,
      onFilter: _filterClients,
      getContentLabel: _getClientContentLabel,
      getListItemLabel: _getClientListItemLabel,
      emptySubtext: 'Crie um novo cliente usando o campo acima',
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
    final clients = await service.findClientsDomain().throwOnFailure();
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
}

class SelectedClient extends Equatable {
  final int? id;
  final String name;

  const SelectedClient({this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}
