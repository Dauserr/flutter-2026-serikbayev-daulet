import 'package:flutter_test/flutter_test.dart';

import 'package:warmup_3_form/validators.dart';

void main() {
  test('name needs two characters', () {
    expect(validateName('A'), isNotNull);
    expect(validateName('Daulet'), isNull);
  });

  test('email needs a real shape', () {
    expect(validateEmail('daulet'), isNotNull);
    expect(validateEmail('daulet@example.com'), isNull);
  });
}
