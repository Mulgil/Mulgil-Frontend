import 'api_client.dart';
import 'auth_api.dart';
import 'auth_store.dart';
import 'google_auth_service.dart';
import 'learning_domain_api.dart';

abstract final class AppServices {
  static final apiClient = ApiClient(
    accessTokenProvider: AuthStore.accessTokenProvider,
  );

  static final learningDomain = LearningDomainApi(apiClient);
  static final auth = AuthApi(apiClient);
  static final googleAuth = GoogleAuthService();
}
