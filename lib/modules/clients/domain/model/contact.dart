import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:kitchen_helper/database/database.dart';

part 'contact.g.dart';

@JsonSerializable()
class Contact extends Entity with EquatableMixin {
  @override
  final int? id;
  final String contact;

  Contact({required this.contact, this.id});

  factory Contact.fromJson(Map<String, dynamic> json) =>
      _$ContactFromJson(json);

  Map<String, dynamic> toJson() => _$ContactToJson(this);

  @override
  List<Object?> get props => [id, contact];
}
