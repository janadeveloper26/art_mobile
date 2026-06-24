import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:art_mobile/features/notifications/domain/repositories/notifications_repository.dart';
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
  final INotificationsRepository repository;

  NotificationsBloc(this.repository) : super(const NotificationsState()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<MarkRead>(_onMarkRead);
    on<MarkAllAsRead>(_onMarkAllAsRead);
    on<DeleteNotification>(_onDeleteNotification);
    on<SetFilter>((event, emit) => emit(state.copyWith(filter: event.filter)));
  }

  Future<void> _onLoadNotifications(LoadNotifications event, Emitter<NotificationsState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final notifications = await repository.getNotifications();
      emit(state.copyWith(notifications: notifications, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
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
