import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'address.g.dart';

@JsonSerializable()
class Address extends Equatable {
  final String identifier;
  final int? cep;
  final String? street;
  final int? number;
  final String? complement;
  final String? neighborhood;
  final String? city;
  final String? state;

  const Address({
    required this.identifier,
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
