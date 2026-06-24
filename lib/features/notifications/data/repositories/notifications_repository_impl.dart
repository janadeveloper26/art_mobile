import 'package:art_mobile/core/network/api_client.dart';
import 'package:art_mobile/features/notifications/domain/models/notification_model.dart';
import 'package:art_mobile/features/notifications/domain/repositories/notifications_repository.dart';

class NotificationsRepositoryImpl implements INotificationsRepository {
  final ApiClient apiClient;

  NotificationsRepositoryImpl({required this.apiClient});

  @override
  Future<List<NotificationModel>> getNotifications() async {
    final response = await apiClient.get('notifications');
    if (response.data != null && response.data['data'] != null) {
      final list = response.data['data'] as List<dynamic>;
      return list.map((json) => NotificationModel.fromJson(json as Map<String, dynamic>)).toList();
    }
    throw Exception('Invalid data format from API');
  }
}
