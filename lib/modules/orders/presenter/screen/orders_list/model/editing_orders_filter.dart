import 'package:equatable/equatable.dart';

import '../../../../domain/domain.dart';
import '../../../../../../common/common.dart';

class EditingOrdersFilter extends Equatable {
  final SelectedClient? client;
  final DateTime? orderDateStart;
  final DateTime? orderDateEnd;
  final DateTime? deliveryDateStart;
  final DateTime? deliveryDateEnd;
  final OrderStatus? status;

  const EditingOrdersFilter({
    this.status,
    this.client,
    this.orderDateStart,
    this.orderDateEnd,
    this.deliveryDateStart,
    this.deliveryDateEnd,
  });

  @override
  List<Object?> get props => [
        status,
        client,
        orderDateStart,
        orderDateEnd,
        deliveryDateStart,
        deliveryDateEnd,
      ];

  OrdersFilter toOrdersFilter() {
    return OrdersFilter(
      status: status,
      clientId: client?.id,
      orderDateStart: orderDateStart,
      orderDateEnd: orderDateEnd,
      deliveryDateStart: deliveryDateStart,
      deliveryDateEnd: deliveryDateEnd,
    );
  }
}
