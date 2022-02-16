import 'package:flutter_modular/flutter_modular.dart';

import 'presenter/edit_client/edit_client_screen.dart';
import 'presenter/clients_list/clients_list_screen.dart';
import 'data/repository/sqlite_address_repository.dart';
import 'data/repository/sqlite_client_repository.dart';
import 'data/repository/sqlite_contact_repository.dart';
import 'domain/domain.dart';

class ClientsModule extends Module {
  @override
  List<Bind<Object>> get binds => [
        Bind<AddressRepository>(
          (i) => SQLiteAddressRepository(i()),
          export: true,
        ),
        Bind<ContactRepository>(
          (i) => SQLiteContactRepository(i()),
          export: true,
        ),
        Bind<ClientRepository>(
          (i) => SQLiteClientRepository(i(), i(), i()),
          export: true,
        ),
        Bind((i) => GetClientsUseCase(i())),
        Bind((i) => GetClientUseCase(i())),
        Bind((i) => SaveClientUseCase(i())),
        Bind((i) => DeleteClientUseCase(i())),
        Bind((i) => GetAddressDataByCepUseCase(i())),
        Bind((i) => GetClientsDomainUseCase(i()), export: true),
        Bind((i) => GetContactsDomainUseCase(i()), export: true),
        Bind((i) => GetAddressDomainUseCase(i()), export: true),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute(
          Modular.initialRoute,
          child: (_, __) => const ClientsListScreen(),
        ),
        ChildRoute('/edit', child: (_, route) {
          if (route.data is! int?) {
            throw Exception(
                'The route /edit only accepts values of type int? as argument');
          }
          return EditClientScreen(id: route.data as int?);
        }),
      ];
}
