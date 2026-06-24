import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:art_mobile/core/theme/theme_manager.dart';
import 'package:art_mobile/core/config/service_locator.dart';
import 'package:art_mobile/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:art_mobile/core/config/service_locator.dart';
import 'package:art_mobile/core/theme/theme_colors.dart';
import '../bloc/notifications_bloc.dart';
import '../../domain/models/notification_model.dart';

/// [NotificationsPage] provides a premium, high-fidelity notification center.
/// Features staggered entrance animations, intelligent filtering, 
/// and specialized iconography for various alert types.
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NotificationsBloc(sl<INotificationsRepository>())..add(LoadNotifications()),
      child: const NotificationsView(),
    );
  }
}

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> with SingleTickerProviderStateMixin {
  late AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: sl<ThemeManager>(),
      builder: (context, _) {
        final isDark = sl<ThemeManager>().isDarkMode;
        return Scaffold(
          backgroundColor: isDark ? ThemeColors.backgroundDark : Colors.white,
          body: SafeArea(
            child: BlocBuilder<NotificationsBloc, NotificationsState>(
              builder: (context, state) {
                return Column(
                  children: [
                    // ---------------------------------------------------------
                    // 1. PREMIUM GRADIENT HEADER (with bubble effect)
                    // ---------------------------------------------------------
                    RepaintBoundary(
                      child: _buildHeader(context, state, isDark),
                    ),
  
                    // ---------------------------------------------------------
                    // 2. FILTER TABS
                    // ---------------------------------------------------------
                    _buildFilterTabs(context, state, isDark),
  
                    // ---------------------------------------------------------
                    // 3. NOTIFICATIONS LIST
                    // ---------------------------------------------------------
                    Expanded(
                      child: state.filteredNotifications.isEmpty 
                          ? _buildEmptyState(isDark) 
                          : _buildList(context, state, isDark),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, NotificationsState state, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6A1B9A), Color(0xFFAB47BC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Decorative Bubble 1 (Top Right)
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), shape: BoxShape.circle),
            ),
          ),
          // Decorative Bubble 2 (Bottom Left)
          Positioned(
            bottom: -40,
            left: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), shape: BoxShape.circle),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                      child: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 18),
                    ),
                  ),
                  if (state.unreadCount > 0)
                    GestureDetector(
                      onTap: () => context.read<NotificationsBloc>().add(MarkAllAsRead()),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                        child: Text('Mark all read', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text('Notifications', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                  if (state.unreadCount > 0) ...[
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFFFFC107), borderRadius: BorderRadius.circular(10)),
                      child: Text('${state.unreadCount} new', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF212121))),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(BuildContext context, NotificationsState state, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          _buildFilterChip(context, 'all', state.filter == 'all', isDark),
          const SizedBox(width: 10),
          _buildFilterChip(context, 'unread', state.filter == 'unread', isDark, count: state.unreadCount),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String filter, bool isActive, bool isDark, {int count = 0}) {
    return GestureDetector(
      onTap: () => context.read<NotificationsBloc>().add(SetFilter(filter)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF6A1B9A) : (isDark ? Colors.white.withOpacity(0.08) : const Color(0xFF6A1B9A).withOpacity(0.08)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '${filter[0].toUpperCase()}${filter.substring(1)}${count > 0 ? ' ($count)' : ''}',
          style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: isActive ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF6A1B9A))),
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, NotificationsState state, bool isDark) {
    final list = state.filteredNotifications;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final notif = list[index];
        return FadeTransition(
          opacity: _entranceController,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero).animate(
              CurvedAnimation(parent: _entranceController, curve: Interval(index * 0.05, 1.0, curve: Curves.easeOut)),
            ),
            child: _buildNotificationItem(context, notif, isDark),
          ),
        );
      },
    );
  }

  Widget _buildNotificationItem(BuildContext context, NotificationModel notif, bool isDark) {
    final iconData = _getIconData(notif.type);
    final iconColor = _getIconColor(notif.type);
    
    return GestureDetector(
      onTap: () => context.read<NotificationsBloc>().add(MarkRead(notif.id)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notif.read 
              ? (isDark ? ThemeColors.surfaceDark : Colors.white) 
              : (isDark ? const Color(0xFF6A1B9A).withOpacity(0.12) : const Color(0xFF6A1B9A).withOpacity(0.04)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notif.read 
                ? (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06)) 
                : (isDark ? const Color(0xFFAB47BC).withOpacity(0.3) : const Color(0xFF6A1B9A).withOpacity(0.15)),
            width: 1.2,
          ),
          boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(isDark ? 0.2 : 0.1), 
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(iconData, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notif.title, 
                    style: GoogleFonts.outfit(
                      fontSize: 13, 
                      fontWeight: notif.read ? FontWeight.w500 : FontWeight.w700, 
                      color: isDark ? Colors.white : const Color(0xFF212121), 
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.body, 
                    style: GoogleFonts.outfit(
                      fontSize: 12, 
                      color: isDark ? Colors.white70 : const Color(0xFF757575), 
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notif.time, 
                    style: GoogleFonts.outfit(
                      fontSize: 11, 
                      color: isDark ? Colors.white30 : const Color(0xFFBDBDBD),
                    ),
                  ),
                ],
              ),
            ),
            // Action & Status
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!notif.read)
                  Container(
                    width: 8, 
                    height: 8, 
                    decoration: const BoxDecoration(color: Color(0xFF6A1B9A), shape: BoxShape.circle),
                  ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => context.read<NotificationsBloc>().add(DeleteNotification(notif.id)),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(LucideIcons.trash2, color: isDark ? Colors.white24 : const Color(0xFFBDBDBD), size: 14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔔', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            'All caught up!', 
            style: GoogleFonts.outfit(
              fontSize: 16, 
              fontWeight: FontWeight.w600, 
              color: isDark ? Colors.white : const Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'No unread notifications', 
            style: GoogleFonts.outfit(
              fontSize: 13, 
              color: isDark ? Colors.white38 : const Color(0xFF9E9E9E),
            ),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  IconData _getIconData(NotificationType type) {
    switch (type) {
      case NotificationType.lesson: return LucideIcons.play;
      case NotificationType.promo: return LucideIcons.gift;
      case NotificationType.review: return LucideIcons.star;
      case NotificationType.achievement: return LucideIcons.trophy;
      case NotificationType.live: return LucideIcons.bell;
      case NotificationType.payment: return LucideIcons.crown;
    }
  }

  Color _getIconColor(NotificationType type) {
    switch (type) {
      case NotificationType.lesson: return const Color(0xFF9C27B0);
      case NotificationType.promo: return const Color(0xFFE91E63);
      case NotificationType.review: return const Color(0xFFFFC107);
      case NotificationType.achievement: return const Color(0xFFFFC107);
      case NotificationType.live: return const Color(0xFFF44336);
      case NotificationType.payment: return const Color(0xFF6A1B9A);
    }
  }
}
