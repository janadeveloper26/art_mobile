import 'package:art_mobile/features/notifications/domain/models/notification_model.dart';

abstract class INotificationsRepository {
  Future<List<NotificationModel>> getNotifications();
}
