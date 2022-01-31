import 'package:intl/intl.dart';

class Formatter {
  static String currency(num number, {bool symbol = true}) {
    return (symbol ? 'R\$' : '') + number.toStringAsFixed(2);
  }

  static String simpleNumber(num number) {
    var numStr = number.toString();
    while (numStr.contains('.') &&
        (numStr.endsWith('0') || numStr.endsWith('.'))) {
      numStr = numStr.substring(0, numStr.length - 1);
    }
    return numStr;
  }

  static String completeDate(DateTime dateTime) {
    final formatter = DateFormat('HH:mm EEEE, dd/MM/yy');
    return formatter.format(dateTime);
  }
}
