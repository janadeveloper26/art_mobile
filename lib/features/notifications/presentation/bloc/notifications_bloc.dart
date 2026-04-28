import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/models/notification_model.dart';

// EVENTS
abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();
  @override
  List<Object> get props => [];
}

class LoadNotifications extends NotificationsEvent {}

class MarkRead extends NotificationsEvent {
  final String id;
  const MarkRead(this.id);
  @override
  List<Object> get props => [id];
}

class MarkAllAsRead extends NotificationsEvent {}

class DeleteNotification extends NotificationsEvent {
  final String id;
  const DeleteNotification(this.id);
  @override
  List<Object> get props => [id];
}

class SetFilter extends NotificationsEvent {
  final String filter; // 'all' | 'unread'
  const SetFilter(this.filter);
  @override
  List<Object> get props => [filter];
}

// STATES
class NotificationsState extends Equatable {
  final List<NotificationModel> notifications;
  final String filter;
  final bool isLoading;

  const NotificationsState({
    this.notifications = const [],
    this.filter = 'all',
    this.isLoading = false,
  });

  List<NotificationModel> get filteredNotifications {
    if (filter == 'unread') {
      return notifications.where((n) => !n.read).toList();
    }
    return notifications;
  }

  int get unreadCount => notifications.where((n) => !n.read).length;

  NotificationsState copyWith({
    List<NotificationModel>? notifications,
    String? filter,
    bool? isLoading,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      filter: filter ?? this.filter,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object> get props => [notifications, filter, isLoading];
}

// BLOC
class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc() : super(const NotificationsState()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<MarkRead>(_onMarkRead);
    on<MarkAllAsRead>(_onMarkAllAsRead);
    on<DeleteNotification>(_onDeleteNotification);
    on<SetFilter>((event, emit) => emit(state.copyWith(filter: event.filter)));
  }

  void _onLoadNotifications(LoadNotifications event, Emitter<NotificationsState> emit) {
    emit(state.copyWith(isLoading: true));
    
    // Mock Data
    final mockNotifs = [
      const NotificationModel(
        id: "n1",
        type: NotificationType.lesson,
        title: "New Lesson Available",
        body: "\"Chain Stitch Basics\" in Aari Embroidery Masterclass is now live!",
        time: "Just now",
        read: false,
      ),
      const NotificationModel(
        id: "n2",
        type: NotificationType.live,
        title: "Live Class Starting Soon",
        body: "Priya Sharma's Live Bridal Embroidery session starts in 30 mins!",
        time: "28 min ago",
        read: false,
      ),
      const NotificationModel(
        id: "n3",
        type: NotificationType.achievement,
        title: "🏆 Achievement Unlocked!",
        body: "You completed 50% of Aari Embroidery Masterclass. Keep going!",
        time: "2 hours ago",
        read: false,
      ),
      const NotificationModel(
        id: "n4",
        type: NotificationType.promo,
        title: "Special Offer — 50% Off!",
        body: "Bridal Blouse Design course is 50% off for the next 24 hours. Use code AARI10.",
        time: "Yesterday",
        read: true,
      ),
      const NotificationModel(
        id: "n5",
        type: NotificationType.payment,
        title: "Subscription Renewed",
        body: "Your Yearly Premium plan has been successfully renewed for ₹1,999.",
        time: "2 days ago",
        read: true,
      ),
      const NotificationModel(
        id: "n6",
        type: NotificationType.review,
        title: "Your Review Was Helpful!",
        body: "12 students found your review of \"Zari & Silk Thread Embroidery\" helpful.",
        time: "3 days ago",
        read: true,
      ),
      const NotificationModel(
        id: "n7",
        type: NotificationType.lesson,
        title: "Resume Where You Left Off",
        body: "You were 70% through \"Introduction to Aari Hook\". Continue now!",
        time: "5 days ago",
        read: true,
      ),
    ];

    emit(state.copyWith(notifications: mockNotifs, isLoading: false));
  }

  void _onMarkRead(MarkRead event, Emitter<NotificationsState> emit) {
    final updated = state.notifications.map((n) {
      if (n.id == event.id) return n.copyWith(read: true);
      return n;
    }).toList();
    emit(state.copyWith(notifications: updated));
  }

  void _onMarkAllAsRead(MarkAllAsRead event, Emitter<NotificationsState> emit) {
    final updated = state.notifications.map((n) => n.copyWith(read: true)).toList();
    emit(state.copyWith(notifications: updated));
  }

  void _onDeleteNotification(DeleteNotification event, Emitter<NotificationsState> emit) {
    final updated = state.notifications.where((n) => n.id != event.id).toList();
    emit(state.copyWith(notifications: updated));
  }
}
