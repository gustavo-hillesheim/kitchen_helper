import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'address_domain_dto.g.dart';

@JsonSerializable(createToJson: false)
class AddressDomainDto extends Equatable {
  final int id;
  final String label;

  const AddressDomainDto({required this.id, required this.label});

  factory AddressDomainDto.fromJson(Map<String, dynamic> json) =>
      _$AddressDomainDtoFromJson(json);

  @override
  List<Object?> get props => [id, label];
}
