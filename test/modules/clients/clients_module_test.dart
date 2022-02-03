import 'package:flutter_modular/flutter_modular.dart';
import 'package:kitchen_helper/app_module.dart';
import 'package:kitchen_helper/database/sqlite/sqlite.dart';
import 'package:kitchen_helper/modules/clients/clients.dart';
import 'package:kitchen_helper/modules/clients/clients_module.dart';
import 'package:modular_test/modular_test.dart';
import 'package:test/test.dart';

import '../../mocks.dart';

void main() {
  test('SHOULD load ClientRepository correctly', () async {
    initModules([
      AppModule(),
      ClientsModule()
    ], replaceBinds: [
      Bind.instance<SQLiteDatabase>(SQLiteDatabaseMock()),
    ]);
    await Modular.isModuleReady<AppModule>();
    await Modular.isModuleReady<ClientsModule>();

    expect(Modular.get<ClientRepository>(), isNotNull);
  });
}
