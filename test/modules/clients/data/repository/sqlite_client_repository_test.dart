import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/core/core.dart';
import 'package:kitchen_helper/database/sqlite/sqlite.dart';
import 'package:kitchen_helper/modules/clients/clients.dart';
import 'package:kitchen_helper/modules/clients/data/repository/sqlite_address_repository.dart';
import 'package:kitchen_helper/modules/clients/data/repository/sqlite_client_repository.dart';
import 'package:kitchen_helper/modules/clients/data/repository/sqlite_contact_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../../mocks.dart';

void main() {
  late SQLiteDatabase database;
  late SQLiteAddressRepository addressRepository;
  late SQLiteContactRepository contactRepository;
  late SQLiteClientRepository repository;

  setUp(() {
    registerFallbackValue(FakeAddressEntity());
    registerFallbackValue(FakeContactEntity());
    database = SQLiteDatabaseMock();
    addressRepository = SQLiteAddressRepositoryMock();
    contactRepository = SQLiteContactRepositoryMock();
    repository =
        SQLiteClientRepository(addressRepository, contactRepository, database);
  });

  group('converters', () {
    test('SHOULD convert to map', () {
      final map = repository.toMap(batmanClient);

      expect(map.length, 2);
      expect(map['id'], batmanClient.id);
      expect(map['name'], batmanClient.name);
    });
    test('SHOULD convert from map', () {
      final client = repository.fromMap({'id': 1, 'name': 'Batman'});

      expect(client, batmanClient.copyWith(addresses: [], contacts: []));
    });
  });

  group('findAllListing', () {
    When<Future<List<Map<String, dynamic>>>> whenQuery() {
      return when(() =>
          database.query(table: repository.tableName, columns: ['id', 'name']));
    }

    test('WHEN database has records SHOULD return DTOs', () async {
      whenQuery().thenAnswer((_) async => [
            {'id': 1, 'name': 'Batman'},
            {'id': 2, 'name': 'Spider man'}
          ]);

      final result = await repository.findAllListing();

      expect(result.getRight().toNullable(), listingClientDtos);
    });

    test('WHEN database throws DatabaseException SHOULD return Failure',
        () async {
      whenQuery().thenThrow(FakeDatabaseException('database exception'));

      final result = await repository.findAllListing();

      expect(
        result.getLeft().toNullable()?.message,
        SQLiteRepository.couldNotFindAllMessage,
      );
    });

    test('WHEN database throws unknown Exception SHOULD throw Exception',
        () async {
      final exception = Exception('some error');
      whenQuery().thenThrow(exception);
      try {
        await repository.findAllListing();
        fail('Should have thrown');
      } catch (e) {
        expect(e, exception);
      }
    });
  });
  When<Future<List<Map<String, dynamic>>>> mockFindClients() {
    return when(() => database.findAll(repository.tableName));
  }

  When<Future<Map<String, dynamic>?>> mockFindClient() {
    return when(
        () => database.findById(repository.tableName, repository.idColumn, 1));
  }

  When<Future<Either<Failure, List<AddressEntity>>>> mockFindAddresses(
      {int? clientId}) {
    return when(() => addressRepository.findByClient(clientId ?? any()));
  }

  When<Future<Either<Failure, List<ContactEntity>>>> mockFindContacts(
      {int? clientId}) {
    return when(() => contactRepository.findByClient(clientId ?? any()));
  }

  group('findById', () {
    test('WHEN has record SHOULD query contacts and addresses', () async {
      mockFindClient().thenAnswer((_) async => {'id': 1, 'name': 'Batman'});
      mockFindAddresses()
          .thenAnswer((_) async => Right(batmanClient.addressEntities()));
      mockFindContacts()
          .thenAnswer((_) async => Right(batmanClient.contactEntities()));

      final result = await repository.findById(1);

      expect(result.getRight().toNullable(), batmanClient);
    });

    test('WHEN has no record SHOULD not query contacts and addresses',
        () async {
      mockFindClient().thenAnswer((_) async => null);

      final result = await repository.findById(1);

      expect(result.getRight().toNullable(), null);
      verifyNever(() => addressRepository.findByClient(any()));
      verifyNever(() => contactRepository.findByClient(any()));
    });

    test(
        'WHEN query throws DatabaseException '
        'SHOULD not query contacts and addresses', () async {
      mockFindClient().thenThrow(FakeDatabaseException('query exception'));

      final result = await repository.findById(1);

      expect(
        result.getLeft().toNullable()?.message,
        SQLiteRepository.couldNotFindMessage,
      );
      verifyNever(() => addressRepository.findByClient(any()));
      verifyNever(() => contactRepository.findByClient(any()));
    });

    test(
        'WHEN address query return Failure '
        'SHOULD not query contacts', () async {
      final failure = FakeFailure('address failure');
      mockFindClient().thenAnswer((_) async => {'id': 1, 'name': 'Batman'});
      mockFindAddresses().thenAnswer((_) async => Left(failure));

      final result = await repository.findById(1);

      expect(result.getLeft().toNullable(), failure);
      verifyNever(() => contactRepository.findByClient(any()));
    });

    test(
        'WHEN contacts query return Failure '
        'SHOULD return Failure', () async {
      final failure = FakeFailure('contact failure');
      mockFindClient().thenAnswer((_) async => {'id': 1, 'name': 'Batman'});
      mockFindAddresses().thenAnswer((_) async => const Right([]));
      mockFindContacts().thenAnswer((_) async => Left(failure));

      final result = await repository.findById(1);

      expect(result.getLeft().toNullable(), failure);
    });
  });

  group('findAll', () {
    test(
        'WHEN has records '
        'SHOULD get addresses and contacts for each', () async {
      mockFindClients().thenAnswer((_) async => [
            {'id': 1, 'name': 'Batman'},
            {'id': 2, 'name': 'Spider man'}
          ]);
      mockFindAddresses().thenAnswer((_) async => const Right([]));
      mockFindContacts().thenAnswer((_) async => const Right([]));

      final result = await repository.findAll();

      expect(result.getRight().toNullable(), [
        batmanClient.copyWith(addresses: [], contacts: []),
        spidermanClient.copyWith(addresses: [], contacts: []),
      ]);
      verify(() => addressRepository.findByClient(1));
      verify(() => addressRepository.findByClient(2));
      verify(() => contactRepository.findByClient(1));
      verify(() => contactRepository.findByClient(2));
    });

    test('WHEN has no records SHOULD not get addresses and contacts', () async {
      mockFindClients().thenAnswer((_) async => []);

      final result = await repository.findAll();

      expect(result.getRight().toNullable(), []);
      verifyNever(() => addressRepository.findByClient(any()));
      verifyNever(() => contactRepository.findByClient(any()));
    });
  });

  void mockTransaction<T>(void Function() verify) {
    return when(() => database.insideTransaction<T>(any()))
        .thenAnswer((invocation) async {
      final result = await invocation.positionalArguments[0]();
      verify();
      return result;
    });
  }

  When<Future<int>> mockInsertClient({required Client client}) {
    return when(
        () => database.insert(repository.tableName, repository.toMap(client)));
  }

  When<Future<void>> mockUpdateClient({required Client client}) {
    return when(() => database.update(
          repository.tableName,
          repository.toMap(client),
          repository.idColumn,
          client.id!,
        ));
  }

  When<Future<Either<Failure, int>>> mockCreateAddress(
      {required Address address, required int clientId}) {
    return when(() => addressRepository.create(
          AddressEntity.fromAddress(address, clientId: clientId),
        ));
  }

  When<Future<Either<Failure, int>>> mockSaveAddress(
      {required Address address, required int clientId}) {
    return when(() => addressRepository.save(
          AddressEntity.fromAddress(address, clientId: clientId),
        ));
  }

  When<Future<Either<Failure, void>>> mockDeleteAddresses(
      {required int clientId}) {
    return when(() => addressRepository.deleteByClient(clientId));
  }

  When<Future<Either<Failure, void>>> mockDeleteAddress({required int id}) {
    return when(() => addressRepository.deleteById(id));
  }

  When<Future<Either<Failure, int>>> mockCreateContact(
      {required Contact contact, required int clientId}) {
    return when(() => contactRepository.create(
          ContactEntity.fromContact(contact, clientId: clientId),
        ));
  }

  When<Future<Either<Failure, int>>> mockSaveContact(
      {required Contact contact, required int clientId}) {
    return when(() => contactRepository.save(
          ContactEntity.fromContact(contact, clientId: clientId),
        ));
  }

  When<Future<Either<Failure, void>>> mockDeleteContacts(
      {required int clientId}) {
    return when(() => contactRepository.deleteByClient(clientId));
  }

  When<Future<Either<Failure, void>>> mockDeleteContact({required int id}) {
    return when(() => contactRepository.deleteById(id));
  }

  group('create', () {
    test('WHEN creates client SHOULD create addresses and contacts', () async {
      mockTransaction<Either<Failure, int>>(() {
        for (final address in batmanClient.addresses) {
          verify(() => addressRepository.create(
                AddressEntity.fromAddress(address, clientId: 2),
              ));
        }
        for (final contact in batmanClient.contacts) {
          verify(() => contactRepository.create(
                ContactEntity.fromContact(contact, clientId: 2),
              ));
        }
      });
      mockInsertClient(client: batmanClient).thenAnswer((_) async => 2);
      for (final address in batmanClient.addresses) {
        mockCreateAddress(address: address, clientId: 2)
            .thenAnswer((_) async => const Right(1));
      }
      for (final contact in batmanClient.contacts) {
        mockCreateContact(contact: contact, clientId: 2)
            .thenAnswer((_) async => const Right(1));
      }

      final result = await repository.create(batmanClient);

      expect(result.getRight().toNullable(), 2);
    });

    test(
        'WHEN has error on create client '
        'SHOULD not create addresses or contacts', () async {
      mockTransaction<Either<Failure, int>>(() {
        verifyNever(() => addressRepository.create(any()));
        verifyNever(() => contactRepository.create(any()));
      });
      mockInsertClient(client: batmanClient)
          .thenThrow(FakeDatabaseException('create error'));

      final result = await repository.create(batmanClient);

      expect(
        result.getLeft().toNullable()?.message,
        SQLiteRepository.couldNotInsertMessage,
      );
    });

    test(
        'WHEN has Failure on create address '
        'SHOULD not create contacts', () async {
      final failure = FakeFailure('address failure');
      mockTransaction<Either<Failure, int>>(() {
        verifyNever(() => contactRepository.create(any()));
      });
      mockInsertClient(client: batmanClient).thenAnswer((_) async => 1);
      mockCreateAddress(address: batmanClient.addresses[0], clientId: 1)
          .thenAnswer((_) async => Left(failure));

      final result = await repository.create(batmanClient);

      expect(result.getLeft().toNullable(), failure);
    });

    test(
        'WHEN has Failure on create contact '
        'SHOULD return Failure', () async {
      final failure = FakeFailure('contact failure');
      mockTransaction<Either<Failure, int>>(() {});
      mockInsertClient(client: batmanClient).thenAnswer((_) async => 1);
      mockCreateAddress(address: batmanClient.addresses[0], clientId: 1)
          .thenAnswer((_) async => const Right(1));
      mockCreateContact(contact: batmanClient.contacts[0], clientId: 1)
          .thenAnswer((_) async => Left(failure));

      final result = await repository.create(batmanClient);

      expect(result.getLeft().toNullable(), failure);
    });
  });

  group('update', () {
    test(
        'WHEN updates client '
        'SHOULD update addresses and contacts', () async {
      mockTransaction<Either<Failure, void>>(() {
        verify(() => contactRepository.findByClient(batmanClient.id!));
        verify(() => addressRepository.findByClient(batmanClient.id!));
        verify(() => addressRepository.save(any()));
        verify(() => contactRepository.save(any()));
        verifyNever(() => contactRepository.deleteById(any()));
        verifyNever(() => addressRepository.deleteById(any()));
      });
      mockUpdateClient(client: batmanClient)
          .thenAnswer((_) async => const Right(null));
      mockFindAddresses(clientId: batmanClient.id)
          .thenAnswer((_) async => Right(batmanClient.addressEntities()));
      mockFindContacts(clientId: batmanClient.id)
          .thenAnswer((_) async => Right(batmanClient.contactEntities()));
      mockSaveAddress(
              address: batmanClient.addresses[0], clientId: batmanClient.id!)
          .thenAnswer((_) async => const Right(1));
      mockSaveContact(
              contact: batmanClient.contacts[0], clientId: batmanClient.id!)
          .thenAnswer((_) async => const Right(1));

      final result = await repository.update(batmanClient);

      expect(result.isRight(), true);
    });

    test(
        'WHEN has Failure on delete address '
        'SHOULD not save contacts', () async {
      final failure = FakeFailure('delete address failure');
      mockTransaction<Either<Failure, void>>(() {
        verify(() => addressRepository.deleteById(10));
        verifyNever(() => contactRepository.findByClient(batmanClient.id!));
        verifyNever(() => addressRepository.create(any()));
        verifyNever(() => contactRepository.create(any()));
      });
      mockUpdateClient(client: batmanClient)
          .thenAnswer((_) async => const Right(null));
      mockFindAddresses(clientId: batmanClient.id)
          .thenAnswer((_) async => Right([
                ...batmanClient.addressEntities(),
                AddressEntity(
                    identifier: 'address', id: 10, clientId: batmanClient.id)
              ]));
      mockDeleteAddress(id: 10).thenAnswer((_) async => Left(failure));

      final result = await repository.update(batmanClient);

      expect(result.getLeft().toNullable(), failure);
    });

    test(
        'WHEN has Failure on save addresses '
        'SHOULD not save contacts', () async {
      final failure = FakeFailure('save address failure');
      mockTransaction<Either<Failure, void>>(() {
        verify(() => addressRepository.save(any()));
        verifyNever(() => contactRepository.findByClient(batmanClient.id!));
        verifyNever(() => contactRepository.save(any()));
      });
      mockUpdateClient(client: batmanClient)
          .thenAnswer((_) async => const Right(null));
      mockFindAddresses(clientId: batmanClient.id)
          .thenAnswer((_) async => Right(batmanClient.addressEntities()));
      mockSaveAddress(
              address: batmanClient.addresses[0], clientId: batmanClient.id!)
          .thenAnswer((_) async => Left(failure));

      final result = await repository.update(batmanClient);

      expect(result.getLeft().toNullable(), failure);
    });

    test(
        'WHEN has Failure on delete a contact '
        'SHOULD not save other contacts', () async {
      final failure = FakeFailure('delete contacts failure');
      mockTransaction<Either<Failure, void>>(() {
        verify(() => addressRepository.save(any()));
        verify(() => contactRepository.deleteById(10));
        verifyNever(() => contactRepository.save(any()));
      });
      mockFindAddresses(clientId: batmanClient.id)
          .thenAnswer((_) async => Right(batmanClient.addressEntities()));
      mockFindContacts(clientId: batmanClient.id)
          .thenAnswer((_) async => Right([
                ...batmanClient.contactEntities(),
                ContactEntity(
                    contact: 'contact', id: 10, clientId: batmanClient.id)
              ]));
      mockUpdateClient(client: batmanClient)
          .thenAnswer((_) async => const Right(null));
      mockSaveAddress(
              address: batmanClient.addresses[0], clientId: batmanClient.id!)
          .thenAnswer((_) async => const Right(1));
      mockDeleteContact(id: 10).thenAnswer((_) async => Left(failure));

      final result = await repository.update(batmanClient);

      expect(result.getLeft().toNullable(), failure);
    });
    test(
        'WHEN save contacts returns Failure '
        'SHOULD return Failure', () async {
      final failure = FakeFailure('save contacts failure');
      mockTransaction<Either<Failure, void>>(() {
        verify(() => addressRepository.findByClient(batmanClient.id!));
        verify(() => contactRepository.findByClient(batmanClient.id!));
        verify(() => addressRepository.save(any()));
        verify(() => contactRepository.save(any()));
      });
      mockFindAddresses(clientId: batmanClient.id)
          .thenAnswer((_) async => Right(batmanClient.addressEntities()));
      mockFindContacts(clientId: batmanClient.id)
          .thenAnswer((_) async => Right(batmanClient.contactEntities()));
      mockUpdateClient(client: batmanClient)
          .thenAnswer((_) async => const Right(null));
      mockDeleteAddresses(clientId: batmanClient.id!)
          .thenAnswer((_) async => const Right(null));
      mockSaveAddress(
              address: batmanClient.addresses[0], clientId: batmanClient.id!)
          .thenAnswer((_) async => const Right(1));
      mockDeleteContacts(clientId: batmanClient.id!)
          .thenAnswer((_) async => const Right(null));
      mockSaveContact(
              contact: batmanClient.contacts[0], clientId: batmanClient.id!)
          .thenAnswer((_) async => Left(failure));

      final result = await repository.update(batmanClient);

      expect(result.getLeft().toNullable(), failure);
    });
  });

  group('findAllDomain', () {
    When<Future<List<Map<String, dynamic>>>> whenQueryDomain() {
      return when(() => database
          .query(table: repository.tableName, columns: ['id', 'name label']));
    }

    test('WHEN database has records SHOULD return dtos', () async {
      whenQueryDomain().thenAnswer((_) async => [
            {'id': 1, 'label': 'Client one'},
            {'id': 2, 'label': 'Client two'},
          ]);

      final result = await repository.findAllDomain();

      expect(result.getRight().toNullable(), const [
        ClientDomainDto(id: 1, label: 'Client one'),
        ClientDomainDto(id: 2, label: 'Client two'),
      ]);
    });

    test('WHEN database throw DatabaseException SHOULD return Failure',
        () async {
      final exception = FakeDatabaseException('error on query');
      whenQueryDomain().thenThrow(exception);

      final result = await repository.findAllDomain();

      expect(
        result.getLeft().toNullable()?.message,
        SQLiteRepository.couldNotFindAllMessage,
      );
    });

    test('WHEN database throws unknown Exception SHOULD throw Exception',
        () async {
      final exception = Exception('some error');
      whenQueryDomain().thenThrow(exception);
      try {
        await repository.findAllDomain();
        fail('Should have thrown');
      } catch (e) {
        expect(e, exception);
      }
    });
  });
}

class SQLiteAddressRepositoryMock extends Mock
    implements SQLiteAddressRepository {}

class SQLiteContactRepositoryMock extends Mock
    implements SQLiteContactRepository {}

extension on Client {
  List<AddressEntity> addressEntities() {
    return addresses
        .map((a) => AddressEntity.fromAddress(a, clientId: this.id))
        .toList();
  }

  List<ContactEntity> contactEntities() {
    return contacts
        .map((c) => ContactEntity.fromContact(c, clientId: this.id))
        .toList();
  }
}
