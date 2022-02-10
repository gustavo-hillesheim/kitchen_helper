import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../../database/database.dart';
import 'contact.dart';
import 'address.dart';

part 'client.g.dart';

@JsonSerializable()
class Client extends Equatable implements Entity<int> {
  @override
  final int? id;
  final String name;
  final List<Address> addresses;
  final List<Contact> contacts;

  const Client({
    this.id,
    required this.name,
    required this.addresses,
    required this.contacts,
  });

  factory Client.fromJson(Map<String, dynamic> json) => _$ClientFromJson(json);

  Map<String, dynamic> toJson() => _$ClientToJson(this);

  @override
  List<Object?> get props => [id, name, addresses, contacts];

  Client copyWith({
    int? id,
    String? name,
    List<Address>? addresses,
    List<Contact>? contacts,
  }) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
      addresses: addresses ?? this.addresses,
      contacts: contacts ?? this.contacts,
    );
  }
}
