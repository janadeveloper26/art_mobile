import 'package:art_mobile/core/network/api_client.dart';
import 'package:art_mobile/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:art_mobile/features/subscription/data/models/subscription_model.dart';

class SubscriptionRepositoryImpl implements ISubscriptionRepository {
  final ApiClient apiClient;

  SubscriptionRepositoryImpl({required this.apiClient});

  @override
  Future<SubscriptionResponse> getSubscriptionData() async {
    try {
      final response = await apiClient.get('payments/plans');
      if (response.data != null && response.data['data'] != null) {
        return SubscriptionResponse.fromJson(response.data['data'] as Map<String, dynamic>);
      } else {
        throw Exception('Invalid API response format for subscriptions');
      }
    } catch (e) {
      rethrow;
    }
  }
}
