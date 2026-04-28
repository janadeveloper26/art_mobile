import 'package:art_mobile/core/network/api_client.dart';
import 'package:art_mobile/features/subscription/data/mock_subscription_repository.dart';
import 'package:art_mobile/features/subscription/data/models/subscription_model.dart';

class SubscriptionRepositoryImpl implements ISubscriptionRepository {
  final ApiClient apiClient;

  SubscriptionRepositoryImpl({required this.apiClient});

  @override
  Future<SubscriptionResponse> getSubscriptionData() async {
    try {
      final response = await apiClient.get('payments/subscriptions');
      // Mapping logic...
      throw UnimplementedError('Real API mapping not yet implemented for SubscriptionResponse');
    } catch (e) {
      rethrow;
    }
  }
}
