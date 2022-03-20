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
      result = await result.bindFuture((_) => _updateAddresses(client)).run();
      result = await result.bindFuture((_) => _updateContacts(client)).run();
      return result;
    });
  }

  Future<Either<Failure, void>> _updateAddresses(Client client) async {
    try {
      final currentAddresses =
          await addressRepository.findByClient(client.id!).throwOnFailure();
      final newAddresses = client.addresses;
      final addressesToDelete =
          _findAddressesToDelete(currentAddresses, newAddresses);
      for (final address in addressesToDelete) {
        await addressRepository.deleteById(address.id!).throwOnFailure();
      }
      for (final address in newAddresses) {
        await addressRepository
            .save(AddressEntity.fromAddress(address, clientId: client.id))
            .throwOnFailure();
      }
      return const Right(null);
    } on Failure catch (f) {
      return Left(f);
    }
  }

  List<AddressEntity> _findAddressesToDelete(
    List<AddressEntity> currentAddresses,
    List<Address> newAddresses,
  ) {
    final result = <AddressEntity>[];
    for (final address in currentAddresses) {
      final exists = newAddresses.any((a) => address.id == a.id);
      if (!exists) {
        result.add(address);
      }
    }
    return result;
  }

  Future<Either<Failure, void>> _updateContacts(Client client) async {
    try {
      final currentContacts =
          await contactRepository.findByClient(client.id!).throwOnFailure();
      final newContacts = client.contacts;
      final contactsToDelete =
          _findContactsToDelete(currentContacts, newContacts);
      for (final contact in contactsToDelete) {
        await contactRepository.deleteById(contact.id!).throwOnFailure();
      }
      for (final contact in newContacts) {
        await contactRepository
            .save(ContactEntity.fromContact(contact, clientId: client.id))
            .throwOnFailure();
      }
      return const Right(null);
    } on Failure catch (f) {
      return Left(f);
    }
  }

  List<ContactEntity> _findContactsToDelete(
    List<ContactEntity> currentContacts,
    List<Contact> newContacts,
  ) {
    final result = <ContactEntity>[];
    for (final contact in currentContacts) {
      final exists = newContacts.any((a) => contact.id == a.id);
      if (!exists) {
        result.add(contact);
      }
    }
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
  Future<Either<Failure, List<ClientDomainDto>>> findAllDomain() async {
    try {
      final result = await database.query(
        table: tableName,
        columns: ['id', 'name label'],
      );
      return Right(result.map(ClientDomainDto.fromJson).toList());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(SQLiteRepository.couldNotFindAllMessage, e));
    }
  }
}
