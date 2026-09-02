import 'api_client.dart';
import 'auth_store.dart';
import 'learning_domain_api.dart';
import 'resource_upload_api.dart';

abstract final class AppServices {
  static final apiClient = ApiClient(
    accessTokenProvider: AuthStore.accessTokenProvider,
  );

  static final learningDomain = LearningDomainApi(apiClient);
  static final resourceUpload = ResourceUploadApi(apiClient);
}
