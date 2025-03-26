import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kitchen_helper/app_module.dart';
import 'package:kitchen_helper/common/widget/client_selector_service.dart';

import 'presenter/edit_client/edit_client_screen.dart';
import 'presenter/clients_list/clients_list_screen.dart';
import 'data/repository/sqlite_address_repository.dart';
import 'data/repository/sqlite_client_repository.dart';
import 'data/repository/sqlite_contact_repository.dart';
import 'domain/domain.dart';

class ClientsModule extends Module {
  @override
  List<Module> get imports => [AppModule()];

  @override
  void binds(Injector i) {
    i.addLazySingleton<AddressRepository>(SQLiteAddressRepository.new);
    i.addLazySingleton<ContactRepository>(SQLiteContactRepository.new);
    i.addLazySingleton<ClientRepository>(SQLiteClientRepository.new);
    i.addLazySingleton(GetClientsUseCase.new);
    i.addLazySingleton(GetClientUseCase.new);
    i.addLazySingleton(SaveClientUseCase.new);
    i.addLazySingleton(DeleteClientUseCase.new);
    i.addLazySingleton(GetAddressDataByCepUseCase.new);
    i.addLazySingleton(GetClientsDomainUseCase.new);
    i.addLazySingleton(GetContactsDomainUseCase.new);
    i.addLazySingleton(GetAddressDomainUseCase.new);
    i.addLazySingleton(ClientSelectorService.new);
  }

  @override
  void routes(RouteManager r) {
    r.child(
      Modular.initialRoute,
      child: (_) => const ClientsListScreen(),
    );
    r.child('/edit', child: (context) {
      final route = ModalRoute.of(context);
      final arguments = route?.settings.arguments;
      if (arguments is! int?) {
        throw Exception(
            'The route /edit only accepts values of type int? as argument');
      }
      return EditClientScreen(id: arguments);
    });
  }
}
