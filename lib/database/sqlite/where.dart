import 'query_operators.dart';

class Where {
  final String? where;
  final List<dynamic>? whereArgs;

  Where(this.where, this.whereArgs);

  factory Where.fromMap(Map<String, dynamic> map) {
    var whereStr = '';
    final whereArgs = [];
    map.forEach((key, filters) {
      filters = filters is List ? filters : [filters];
      for (final filter in filters) {
        if (whereStr.isNotEmpty) {
          whereStr += ' AND ';
        }
        if (filter is QueryOperator) {
          whereStr += '$key ${filter.operation}';
          whereArgs.add(filter.value);
        } else {
          whereStr += '$key = ?';
          whereArgs.add(filter);
        }
      }
    });
    return Where(
      whereStr.isEmpty ? null : whereStr,
      whereStr.isEmpty ? null : whereArgs,
    );
  }
}
