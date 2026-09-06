import 'api_client.dart';
import 'auth_api.dart';
import 'auth_store.dart';
import 'google_auth_service.dart';
import 'learning_domain_api.dart';
import 'resource_upload_api.dart';

abstract final class AppServices {
  static final ApiClient apiClient = ApiClient(
    accessTokenProvider: AuthStore.accessTokenProvider,
    onUnauthorized: () => auth.refreshAccessToken(),
  );

  static final learningDomain = LearningDomainApi(apiClient);
  static final resourceUpload = ResourceUploadApi(apiClient);
  static final AuthApi auth = AuthApi(apiClient);
  static final googleAuth = GoogleAuthService();
}
