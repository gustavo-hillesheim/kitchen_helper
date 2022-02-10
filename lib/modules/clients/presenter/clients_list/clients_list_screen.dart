import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../edit_client/edit_client_screen.dart';
import 'widgets/client_list_tile.dart';
import '../../clients.dart';
import 'clients_list_bloc.dart';
import '../../../../../common/common.dart';

class ClientsListScreen extends StatefulWidget {
  final ClientsListBloc? bloc;

  const ClientsListScreen({Key? key, this.bloc}) : super(key: key);

  @override
  State<ClientsListScreen> createState() => _ClientsListScreenState();
}

class _ClientsListScreenState extends State<ClientsListScreen> {
  late final ClientsListBloc bloc;

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
    bloc.load();
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
      onAdd: _goToEditClientScreen,
    );
  }

  void _goToEditClientScreen([ListingClientDto? client]) async {
    final shouldReload = await EditClientScreen.navigate(client?.id);
    if (shouldReload ?? false) {
      bloc.load();
    }
  }
}
