import 'package:flutter_test/flutter_test.dart';
import 'package:mulgil/data/auth_store.dart';

void main() {
  tearDown(AuthStore.clear);

  group('AuthStore', () {
    test('keeps the existing mock login flag working', () {
      AuthStore.isLoggedIn = true;

      expect(AuthStore.isLoggedIn, isTrue);
      expect(AuthStore.accessToken, isNull);
    });

    test('stores tokens for API requests', () async {
      AuthStore.saveTokens(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
      );

      expect(AuthStore.isLoggedIn, isTrue);
      expect(AuthStore.refreshToken, 'refresh-token');
      expect(await AuthStore.accessTokenProvider(), 'access-token');
    });

    test('clears tokens on logout', () {
      AuthStore.saveTokens(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
      );

      AuthStore.isLoggedIn = false;

      expect(AuthStore.isLoggedIn, isFalse);
      expect(AuthStore.accessToken, isNull);
      expect(AuthStore.refreshToken, isNull);
    });
  });
}
