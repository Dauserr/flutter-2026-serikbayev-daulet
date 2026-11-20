import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:users_api/features/users/user.dart';

const userJson = r'''
{
  "id": 1,
  "name": "Leanne Graham",
  "username": "Bret",
  "email": "Sincere@april.biz",
  "address": {
    "street": "Kulas Light",
    "suite": "Apt. 556",
    "city": "Gwenborough",
    "zipcode": "92998-3874",
    "geo": {
      "lat": "-37.3159",
      "lng": "81.1496"
    }
  },
  "phone": "1-770-736-8031 x56442",
  "website": "hildegard.org",
  "company": {
    "name": "Romaguera-Crona",
    "catchPhrase": "Multi-layered client-server neural-net",
    "bs": "harness real-time e-markets"
  }
}
''';

void main() {
  test('parses the real user JSON', () {
    final user = User.fromJson(jsonDecode(userJson) as Map<String, dynamic>);

    expect(user.name, 'Leanne Graham');
    expect(user.address.city, 'Gwenborough');
    expect(user.address.geo.lat, -37.3159);
    expect(user.website, 'hildegard.org');
    expect(user.phoneDigits, '1770736803156442');
  });

  test('throws when id is a string', () {
    final data = jsonDecode(userJson) as Map<String, dynamic>;
    data['id'] = '1';

    expect(() => User.fromJson(data), throwsA(isA<TypeError>()));
  });

  test('Geo rejects a numeric lat', () {
    final data = jsonDecode(userJson) as Map<String, dynamic>;
    final geo = data['address']['geo'] as Map<String, dynamic>;
    geo['lat'] = -37.3159;

    expect(() => Geo.fromJson(geo), throwsA(isA<TypeError>()));
  });
}
