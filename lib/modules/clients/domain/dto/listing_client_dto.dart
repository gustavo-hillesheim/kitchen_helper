import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../../common/common.dart';
part 'listing_client_dto.g.dart';

@JsonSerializable(createToJson: false)
class ListingClientDto extends Equatable implements ListingDto {
  @override
  final int id;
  final String name;

  const ListingClientDto({required this.id, required this.name});

  factory ListingClientDto.fromJson(Map<String, dynamic> json) =>
      _$ListingClientDtoFromJson(json);

  @override
  List<Object?> get props => [id, name];
}
