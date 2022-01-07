import 'package:kitchen_helper/database/sqlite/sqlite.dart';
import 'package:kitchen_helper/domain/domain.dart';

class SQLiteOrderRepository extends SQLiteRepository<Order>
    implements OrderRepository {
  SQLiteOrderRepository(SQLiteDatabase database)
      : super(
          'orders',
          'id',
          database,
          fromMap: (map) {
            map = Map.from(map);
            map['products'] = [];
            return Order.fromJson(map);
          },
          toMap: (order) {
            final map = order.toJson();
            map.remove('products');
            return map;
          },
        );
}
