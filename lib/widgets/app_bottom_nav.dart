import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:art_mobile/core/theme/theme_manager.dart';
import 'package:art_mobile/core/config/service_locator.dart';
import 'package:art_mobile/core/theme/theme_colors.dart';

class AppBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const AppBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: sl<ThemeManager>(),
      builder: (context, _) {
        final isDark = sl<ThemeManager>().isDarkMode;
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? ThemeColors.surfaceDark : Colors.white,
            border: Border(
              top: BorderSide(
                color: isDark ? ThemeColors.borderDark : const Color(0xFF6A1B9A).withOpacity(0.1), 
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                _buildNavItem(0, LucideIcons.home, "Home", isDark),
                _buildNavItem(1, LucideIcons.compass, "Explore", isDark),
                _buildNavItem(2, LucideIcons.bookOpen, "My Courses", isDark),
                _buildNavItem(3, LucideIcons.user, "Profile", isDark),
                _buildNavItem(4, LucideIcons.shoppingBag, "Supply", isDark),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, bool isDark) {
    final bool active = selectedIndex == index;
    
    final activeColor = isDark ? const Color(0xFFAB47BC) : const Color(0xFF6A1B9A);
    final inactiveColor = isDark ? Colors.grey.shade600 : const Color(0xFFBDBDBD);

    return Expanded(
      child: InkWell(
        onTap: () => onItemSelected(index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: active ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 10,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                color: active ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
