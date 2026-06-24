import 'package:art_mobile/features/subscription/data/models/subscription_model.dart';

abstract class ISubscriptionRepository {
  Future<SubscriptionResponse> getSubscriptionData();
}
