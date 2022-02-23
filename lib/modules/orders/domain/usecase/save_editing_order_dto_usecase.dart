import 'package:fpdart/fpdart.dart' hide Order;

import '../../../clients/clients.dart';
import '../../../../core/core.dart';
import '../../../../extensions.dart';
import '../domain.dart';

class SaveEditingOrderDtoUseCase extends UseCase<EditingOrderDto, Order> {
  static const clientIdOrNameAreRequiredMessage =
      'É necessário informar o id ou nome do cliente';
  static const cantSaveWithClientNAmeAndIdMessage =
      'Não é possível informar id e nome do contato ao mesmo tempo';
  static const cantSaveWithClientContactAndContactIdMessage =
      'Não é possível informar id e valor de contato ao mesmo tempo';
  static const cantSaveWithClientAddressAndAddressIdMessage =
      'Não é possível informar id e valor de endereço ao mesmo tempo';

  final OrderRepository repository;
  final ClientRepository clientRepository;
  final AddressRepository addressRepository;
  final ContactRepository contactRepository;

  SaveEditingOrderDtoUseCase(this.repository, this.clientRepository,
      this.addressRepository, this.contactRepository);

  @override
  Future<Either<Failure, Order>> execute(EditingOrderDto dto) async {
    if (dto.clientId == null && dto.clientName == null) {
      return const Left(BusinessFailure(clientIdOrNameAreRequiredMessage));
    }
    if (dto.clientId != null && dto.clientName != null) {
      return const Left(BusinessFailure(cantSaveWithClientNAmeAndIdMessage));
    }
    if (dto.clientContact != null && dto.contactId != null) {
      return const Left(
          BusinessFailure(cantSaveWithClientContactAndContactIdMessage));
    }
    if (dto.clientAddress != null && dto.addressId != null) {
      return const Left(
          BusinessFailure(cantSaveWithClientAddressAndAddressIdMessage));
    }
    return _save(dto);
  }

  Future<Either<Failure, Order>> _save(EditingOrderDto dto) async {
    return _saveClientIfNeeded(dto).onRightThen((clientId) =>
        _saveAddressIfNeeded(dto, clientId).onRightThen((addressId) =>
            _saveContactIfNeeded(dto, clientId).onRightThen((contactId) {
              final order = _createOrder(
                dto,
                clientId: clientId,
                addressId: addressId,
                contactId: contactId,
              );
              return repository
                  .save(order)
                  .onRightThen((id) => Right(order.copyWith(id: id)));
            })));
  }

  Future<Either<Failure, int>> _saveClientIfNeeded(EditingOrderDto dto) async {
    if (dto.clientId != null) {
      return Right(dto.clientId!);
    } else {
      return clientRepository.save(Client(
        name: dto.clientName!,
        addresses: const [],
        contacts: const [],
      ));
    }
  }

  Future<Either<Failure, int?>> _saveAddressIfNeeded(
      EditingOrderDto dto, int clientId) async {
    if (dto.addressId != null) {
      return Right(dto.addressId);
    } else if (dto.clientAddress?.isNotEmpty ?? false) {
      return addressRepository.save(AddressEntity(
        identifier: dto.clientAddress!,
        clientId: clientId,
      ));
    } else {
      return const Right(null);
    }
  }

  Future<Either<Failure, int?>> _saveContactIfNeeded(
      EditingOrderDto dto, int clientId) async {
    if (dto.contactId != null) {
      return Right(dto.contactId);
    } else if (dto.clientContact?.isNotEmpty ?? false) {
      return contactRepository.save(ContactEntity(
        contact: dto.clientContact!,
        clientId: clientId,
      ));
    } else {
      return const Right(null);
    }
  }

  Order _createOrder(
    EditingOrderDto dto, {
    required int clientId,
    required int? addressId,
    required int? contactId,
  }) {
    return Order(
      id: dto.id,
      clientId: clientId,
      contactId: contactId,
      addressId: addressId,
      orderDate: dto.orderDate,
      deliveryDate: dto.deliveryDate,
      status: dto.status,
      products: dto.products.map(_createProduct).toList(),
      discounts: dto.discounts.toList(),
    );
  }

  OrderProduct _createProduct(EditingOrderProductDto dto) {
    return OrderProduct(id: dto.id, quantity: dto.quantity);
  }
}
