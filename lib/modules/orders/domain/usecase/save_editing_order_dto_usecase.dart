import 'package:fpdart/fpdart.dart' as fp;

import '../../../../core/core.dart';
import '../../../../extensions.dart';
import '../domain.dart';

class SaveEditingOrderDtoUseCase extends UseCase<EditingOrderDto, Order> {
  final OrderRepository repository;

  SaveEditingOrderDtoUseCase(this.repository);

  @override
  Future<fp.Either<Failure, Order>> execute(EditingOrderDto dto) async {
    final order = _createOrder(dto);
    return repository
        .save(order)
        .onRightThen((id) => fp.Right(order.copyWith(id: id)));
  }

  Order _createOrder(EditingOrderDto dto) {
    return Order(
      id: dto.id,
      clientId: dto.clientId!,
      contactId: dto.contactId,
      addressId: dto.addressId,
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
