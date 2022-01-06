class Formatter {
  static String money(num number) {
    return 'R\$${number.toStringAsFixed(2)}';
  }

  static String simple(num number) {
    var numStr = number.toString();
    while (numStr.contains('.') &&
        (numStr.endsWith('0') || numStr.endsWith('.'))) {
      numStr = numStr.substring(0, numStr.length - 1);
    }
    return numStr;
  }
}
