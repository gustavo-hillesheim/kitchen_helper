import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'address.g.dart';

@JsonSerializable()
class Address extends Equatable {
  final int cep;
  final String street;
  final int number;
  final String? complement;
  final String neighborhood;
  final String city;
  final String state;

  const Address({
    required this.cep,
    required this.street,
    required this.number,
    required this.complement,
    required this.neighborhood,
    required this.city,
    required this.state,
  });

  factory Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);

  Map<String, dynamic> toJson() => _$AddressToJson(this);

  @override
  List<Object?> get props => [
        cep,
        street,
        number,
        complement,
        neighborhood,
        city,
        state,
      ];
}
