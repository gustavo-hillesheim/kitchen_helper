import 'package:flutter_modular/flutter_modular.dart';
import 'package:kitchen_helper/database/sqlite/sqlite.dart';
import 'package:kitchen_helper/modules/clients/clients.dart';
import 'package:kitchen_helper/modules/clients/clients_module.dart';
import 'package:modular_test/modular_test.dart';
import 'package:test/test.dart';

import '../../mocks.dart';

void main() {
  test('SHOULD load ClientRepository correctly', () async {
    initModules([FakeModule(), ClientsModule()]);
    await Modular.isModuleReady<ClientsModule>();

    expect(Modular.get<ClientRepository>(), isNotNull);
  });
}

class FakeModule extends Module {
  @override
  List<Bind<Object>> get binds => [
        Bind.instance<SQLiteDatabase>(SQLiteDatabaseMock()),
      ];
}
