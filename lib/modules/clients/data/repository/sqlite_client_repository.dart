import 'package:fpdart/fpdart.dart';
import 'package:sqflite/sqflite.dart';

import '../../clients.dart';
import 'sqlite_address_repository.dart';
import 'sqlite_contact_repository.dart';
import '../../../../core/failure.dart';
import '../../../../extensions.dart';
import '../../../../database/sqlite/sqlite.dart';

class SQLiteClientRepository extends SQLiteRepository<Client>
    implements ClientRepository {
  final SQLiteAddressRepository addressRepository;
  final SQLiteContactRepository contactRepository;

  SQLiteClientRepository(
      this.addressRepository, this.contactRepository, SQLiteDatabase database)
      : super(
          'clients',
          'id',
          database,
          fromMap: (map) {
            map = Map.from(map);
            map['addresses'] = [];
            map['contacts'] = [];
            return Client.fromJson(map);
          },
          toMap: (client) {
            final map = client.toJson();
            map.remove('addresses');
            map.remove('contacts');
            return map;
          },
        );

  @override
  Future<Either<Failure, List<ListingClientDto>>> findAllListing() async {
    try {
      final result = await database.query(
        table: tableName,
        columns: ['id', 'name'],
      );
      return Right(result.map(ListingClientDto.fromJson).toList());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(SQLiteRepository.couldNotFindAllMessage, e));
    }
  }

  @override
  Future<Either<Failure, Client?>> findById(int id) async {
    var result = await super.findById(id);
    return result.bindFuture<Client?>((client) async {
      if (client != null) {
        var result = await _withAddresses(client);
        result = await result.bindFuture(_withContacts).run();
        return result;
      }
      return Right(client);
    }).run();
  }

  @override
  Future<Either<Failure, List<Client>>> findAll() async {
    return await super.findAll().onRightThen((clients) async {
      final result = await Future.wait(clients.map((client) async {
        var result = await _withAddresses(client);
        result = await result.bindFuture(_withContacts).run();
        return result;
      }));
      return result.asEitherList();
    });
  }

  Future<Either<Failure, Client>> _withAddresses(Client client) async {
    final result = await addressRepository.findByClient(client.id!);
    return result.map((addresses) {
      return client.copyWith(
        addresses: addresses.map((a) => a.toAddress()).toList(),
      );
    });
  }

  Future<Either<Failure, Client>> _withContacts(Client client) async {
    final result = await contactRepository.findByClient(client.id!);
    return result.map((contacts) {
      return client.copyWith(
        contacts: contacts.map((c) => c.toContact()).toList(),
      );
    });
  }

  @override
  Future<Either<Failure, int>> create(Client client) async {
    return database.insideTransaction(() async {
      var result = await super.create(client);
      result = await result
          .bindFuture((id) => _createAddresses(client.addresses, id))
          .run();
      result = await result
          .bindFuture((id) => _createContacts(client.contacts, id))
          .run();
      return result;
    });
  }

  @override
  Future<Either<Failure, void>> update(Client client) async {
    return database.insideTransaction(() async {
      var result = await super.update(client);
      result = await result.bindFuture((_) => _recreateAddresses(client)).run();
      result = await result.bindFuture((_) => _recreateContacts(client)).run();
      return result;
    });
  }

  Future<Either<Failure, void>> _recreateAddresses(Client client) async {
    var result = await addressRepository.deleteByClient(client.id!);
    result = await result
        .bindFuture((_) => _createAddresses(client.addresses, client.id!))
        .run();
    return result;
  }

  Future<Either<Failure, void>> _recreateContacts(Client client) async {
    var result = await contactRepository.deleteByClient(client.id!);
    result = await result
        .bindFuture((_) => _createContacts(client.contacts, client.id!))
        .run();
    return result;
  }

  Future<Either<Failure, int>> _createAddresses(
      List<Address> addresses, int clientId) async {
    for (final address in addresses) {
      final result = await addressRepository.create(
        AddressEntity.fromAddress(address, clientId: clientId),
      );
      if (result.isLeft()) {
        return result;
      }
    }
    return Right(clientId);
  }

  Future<Either<Failure, int>> _createContacts(
      List<Contact> contacts, int clientId) async {
    for (final contact in contacts) {
      final result = await contactRepository.create(
        ContactEntity.fromContact(contact, clientId: clientId),
      );
      if (result.isLeft()) {
        return result;
      }
    }
    return Right(clientId);
  }

  @override
  Future<Either<Failure, List<ClientDomainDto>>> findAllDomain() {
    // TODO: implement findAllDomain
    throw UnimplementedError();
  }
}
