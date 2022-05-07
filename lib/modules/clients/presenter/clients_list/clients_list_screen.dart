import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../edit_client/edit_client_screen.dart';
import '../../clients.dart';
import '../../../../../common/common.dart';
import 'widgets/clients_filter_display.dart';
import 'widgets/client_list_tile.dart';
import 'clients_list_bloc.dart';

class ClientsListScreen extends StatefulWidget {
  final ClientsListBloc? bloc;

  const ClientsListScreen({Key? key, this.bloc}) : super(key: key);

  @override
  State<ClientsListScreen> createState() => _ClientsListScreenState();
}

class _ClientsListScreenState extends State<ClientsListScreen> {
  late final ClientsListBloc bloc;
  ClientsFilter? lastFilter;

  @override
  void initState() {
    super.initState();
    bloc = widget.bloc ??
        ClientsListBloc(
          Modular.get(),
          Modular.get(),
          Modular.get(),
          Modular.get(),
        );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return ListPageTemplate<ListingClientDto, Client>(
      title: 'Clientes',
      bloc: bloc,
      tileBuilder: (_, client) => ClientListTile(
        client,
        onTap: () => _goToEditClientScreen(client),
      ),
      deletedMessage: (client) => '${client.name} foi excluído',
      emptyText: 'Sem clientes',
      emptySubtext: 'Adicione clientes e eles aparecerão aqui',
      emptyActionText: 'Adicionar clientes',
      headerBottom: ClientsFilterDisplay(
        onChange: (newFilter) => _load(newFilter?.toClientsFilter()),
      ),
      onAdd: _goToEditClientScreen,
    );
  }

  Future<void> _load([ClientsFilter? filter]) {
    if (filter != null) {
      lastFilter = filter;
    }
    return bloc.load(lastFilter);
  }

  void _goToEditClientScreen([ListingClientDto? client]) async {
    final shouldReload = await EditClientScreen.navigate(client?.id);
    if (shouldReload ?? false) {
      bloc.load();
    }
  }
}
