import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'client_domain_dto.g.dart';

@JsonSerializable(createToJson: false)
class ClientDomainDto extends Equatable {
  final int id;
  final String label;

  const ClientDomainDto({required this.id, required this.label});

  factory ClientDomainDto.fromJson(Map<String, dynamic> json) =>
      _$ClientDomainDtoFromJson(json);

  @override
  List<Object?> get props => [id, label];
}
