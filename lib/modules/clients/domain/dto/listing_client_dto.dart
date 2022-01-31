import 'package:equatable/equatable.dart';

class ListingClientDto extends Equatable {
  final int id;
  final String name;

  const ListingClientDto({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}
