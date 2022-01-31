import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/core.dart';
import '../../../../database/database.dart';
import '../../../../database/sqlite/sqlite.dart';
import '../../domain/model/contact.dart';

part 'sqlite_contact_repository.g.dart';

class SQLiteContactRepository extends SQLiteRepository<ContactEntity> {
  SQLiteContactRepository(SQLiteDatabase database)
      : super(
          'clientContacts',
          'id',
          database,
          toMap: (contact) => contact.toJson(),
          fromMap: (map) => ContactEntity.fromJson(map),
        );

  Future<Either<Failure, List<ContactEntity>>> findByClient(
      int clientId) async {
    try {
      final result = await database.query(
        table: tableName,
        columns: ['id', 'clientId', 'contact'],
        where: {'clientId': clientId},
      );
      return Right(result.map(ContactEntity.fromJson).toList());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(SQLiteRepository.couldNotFindAllMessage, e));
    }
  }

  Future<Either<Failure, void>> deleteByClient(int clientId) async {
    try {
      await database.delete(table: tableName, where: {'clientId': clientId});
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(SQLiteRepository.couldNotDeleteMessage, e));
    }
  }
}

@JsonSerializable()
class ContactEntity extends Equatable implements Entity<int> {
  @override
  final int? id;
  final int? clientId;
  final String contact;

  const ContactEntity({this.id, required this.contact, this.clientId});

  ContactEntity.fromContact(Contact contact, {this.clientId})
      : id = null,
        contact = contact.contact;

  factory ContactEntity.fromJson(Map<String, dynamic> json) =>
      _$ContactEntityFromJson(json);

  Map<String, dynamic> toJson() => _$ContactEntityToJson(this);

  Contact toContact() => Contact(contact: contact);

  @override
  List<Object?> get props => [id, clientId, contact];
}
