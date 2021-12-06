import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/presenter/presenter.dart';

void main() {
  test('Should validate required values correctly', () {
    expect(Validator.required(null), Validator.requiredValueMessage);
    expect(Validator.required(''), Validator.requiredValueMessage);
    expect(Validator.required('123'), null);
    expect(Validator.required(123), null);
  });
}
