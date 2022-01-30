import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:kitchen_helper/domain/models/measurement_unit.dart';

part 'recipe_domain_dto.g.dart';

@JsonSerializable(createToJson: false)
class RecipeDomainDto extends Equatable {
  final int id;
  final String label;
  final MeasurementUnit measurementUnit;

  const RecipeDomainDto({
    required this.id,
    required this.label,
    required this.measurementUnit,
  });

  factory RecipeDomainDto.fromJson(Map<String, dynamic> json) =>
      _$RecipeDomainDtoFromJson(json);

  @override
  List<Object?> get props => [id, label];
}
