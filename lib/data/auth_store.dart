// In-memory stand-in for a persisted session — replace with a token check
// against secure storage once real auth is wired up.
abstract final class AuthStore {
  static bool isLoggedIn = false;
}
