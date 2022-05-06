import 'package:equatable/equatable.dart';
import 'package:kitchen_helper/modules/clients/clients.dart';

class EditingClientsFilter extends Equatable {
  final String? name;

  const EditingClientsFilter({this.name});

  @override
  List<Object?> get props => [name];

  ClientsFilter toClientsFilter() {
    return ClientsFilter(
      name: name,
    );
  }
}
