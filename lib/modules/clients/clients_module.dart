import 'package:flutter_modular/flutter_modular.dart';
import 'package:kitchen_helper/modules/clients/presenter/clients_list/clients_list_screen.dart';

import 'data/repository/sqlite_address_repository.dart';
import 'data/repository/sqlite_client_repository.dart';
import 'data/repository/sqlite_contact_repository.dart';
import 'domain/domain.dart';

class ClientsModule extends Module {
  @override
  List<Bind<Object>> get binds => [
        Bind((i) => SQLiteAddressRepository(i())),
        Bind((i) => SQLiteContactRepository(i())),
        Bind<ClientRepository>((i) => SQLiteClientRepository(i(), i(), i())),
        Bind((i) => GetClientsUseCase(i())),
        Bind((i) => GetClientUseCase(i())),
        Bind((i) => SaveClientUseCase(i())),
        Bind((i) => DeleteClientUseCase(i())),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute(
          Modular.initialRoute,
          child: (_, __) => const ClientsListScreen(),
        ),
      ];
}
