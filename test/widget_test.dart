import 'package:flutter_test/flutter_test.dart';
import 'package:silhouette_app/services/auth_service.dart';

void main() {
  test('AppUser parses server response', () {
    final user = AppUser.fromJson({
      'id': '1',
      'name': '月蚀信使',
      'email': 'user@example.com',
    });
    expect(user.name, '月蚀信使');
    expect(user.email, 'user@example.com');
  });
}
