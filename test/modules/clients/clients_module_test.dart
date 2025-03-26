import 'package:flutter_modular/flutter_modular.dart';
import 'package:kitchen_helper/database/sqlite/sqlite.dart';
import 'package:kitchen_helper/modules/clients/clients.dart';
import 'package:kitchen_helper/modules/clients/clients_module.dart';
import 'package:test/test.dart';

import '../../mocks.dart';

void main() {
  test('SHOULD load ClientRepository correctly', () async {
    Modular.bindModule(FakeModule());
    Modular.bindModule(ClientsModule());

    expect(Modular.get<ClientRepository>(), isNotNull);
  });
}

class FakeModule extends Module {
  @override
  void binds(Injector i) {
    i.addInstance<SQLiteDatabase>(SQLiteDatabaseMock());
  }
}
