import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../../core/core.dart';
import '../../../../database/database.dart';
import '../../clients.dart';

part 'contact_repository.g.dart';

abstract class ContactRepository extends Repository<ContactEntity, int> {
  Future<Either<Failure, List<ContactDomainDto>>> findAllDomain(int clientId);
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
