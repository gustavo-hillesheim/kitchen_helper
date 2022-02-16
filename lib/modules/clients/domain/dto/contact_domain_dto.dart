import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'contact_domain_dto.g.dart';

@JsonSerializable(createToJson: false)
class ContactDomainDto extends Equatable {
  final int id;
  final String label;

  const ContactDomainDto({required this.id, required this.label});

  factory ContactDomainDto.fromJson(Map<String, dynamic> json) =>
      _$ContactDomainDtoFromJson(json);

  @override
  List<Object?> get props => [id, label];
}
