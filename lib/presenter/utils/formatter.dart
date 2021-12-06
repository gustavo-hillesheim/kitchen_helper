class Formatter {
  static String price(double price) {
    return 'R\$${price.toStringAsFixed(2)}';
  }

  static String simple(double number) {
    var numStr = number.toString();
    while (numStr.contains('.') &&
        (numStr.endsWith('0') || numStr.endsWith('.'))) {
      numStr = numStr.substring(0, numStr.length - 1);
    }
    return numStr;
  }
}
