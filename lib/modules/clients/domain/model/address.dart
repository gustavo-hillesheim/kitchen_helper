import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:kitchen_helper/database/database.dart';

import 'states.dart';

part 'address.g.dart';

@JsonSerializable()
class Address extends Entity with EquatableMixin {
  @override
  final int? id;
  final String identifier;
  final int? cep;
  final String? street;
  final int? number;
  final String? complement;
  final String? neighborhood;
  final String? city;
  final States? state;

  Address({
    required this.identifier,
    this.id,
    this.cep,
    this.street,
    this.number,
    this.complement,
    this.neighborhood,
    this.city,
    this.state,
  });

  factory Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);

  Map<String, dynamic> toJson() => _$AddressToJson(this);

  @override
  List<Object?> get props => [
        id,
        identifier,
        cep,
        street,
        number,
        complement,
        neighborhood,
        city,
        state,
      ];
}
