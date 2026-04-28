import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:art_mobile/core/theme/theme_manager.dart';
import 'package:art_mobile/core/config/service_locator.dart';
import '../../../../core/theme/theme_colors.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: sl<ThemeManager>(),
      builder: (context, _) {
        final isDark = sl<ThemeManager>().isDarkMode;
        return Scaffold(
          backgroundColor: isDark ? ThemeColors.backgroundDark : const Color(0xFFFBF8F6),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: const CircleAvatar(
                backgroundImage: AssetImage('assets/images/profile_avatar.png'),
              ),
            ),
            title: Text(
              'Activity',
              style: GoogleFonts.playfairDisplay(
                color: isDark ? Colors.white : ThemeColors.burgundy,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(LucideIcons.search, color: isDark ? Colors.white : ThemeColors.textDark),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tabs
                    Row(
                      children: [
                        _buildTab('Recent activity', true, isDark),
                        const SizedBox(width: 32),
                        _buildTab('Completed courses', false, isDark),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Activity Cards
                    _buildActivityCard(
                      title: 'Mastering the Zardosi Stitch',
                      subtitle: 'Watched 2 hours ago',
                      progress: 0.85,
                      imagePath: 'assets/images/zardosi_activity.png',
                      isDark: isDark,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _buildActivityCard(
                      title: 'Intro to Advanced Draping',
                      subtitle: 'Watched yesterday',
                      progress: 0.40,
                      imagePath: 'assets/images/draping_activity.png',
                      isDark: isDark,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _buildActivityCard(
                      title: 'Color Theory in Couture',
                      subtitle: 'Watched 3 days ago',
                      progress: 1.0,
                      isCompleted: true,
                      imagePath: 'assets/images/theory_activity.png',
                      isDark: isDark,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Show All Activity Button
                    Center(
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          backgroundColor: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFEFE9E7),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'SHOW ALL ACTIVITY',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white70 : ThemeColors.textDark,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(LucideIcons.chevronRight, size: 14, color: isDark ? Colors.white70 : ThemeColors.textDark),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 48),
                    
                    // Learning Streak Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2A1F22) : const Color(0xFFF9F3F4),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'LEARNING STREAK',
                                  style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: ThemeColors.burgundy,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  '12 Days',
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : ThemeColors.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(LucideIcons.flame, color: ThemeColors.burgundy, size: 32),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTab(String label, bool isActive, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive 
                ? (isDark ? Colors.white : ThemeColors.burgundy) 
                : Colors.grey.shade400,
          ),
        ),
        const SizedBox(height: 8),
        if (isActive)
          Container(
            height: 2,
            width: 80,
            decoration: BoxDecoration(
              color: ThemeColors.burgundy,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
      ],
    );
  }

  Widget _buildActivityCard({
    required String title,
    required String subtitle,
    required double progress,
    required String imagePath,
    bool isCompleted = false,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? ThemeColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Thumbnail
          Stack(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: AssetImage(imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              if (isCompleted)
                Positioned(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Icon(LucideIcons.checkCircle2, color: Colors.white, size: 24),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isCompleted)
                  Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF332020) : const Color(0xFFF3E5E9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'COMPLETED',
                      style: GoogleFonts.outfit(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: ThemeColors.burgundy,
                      ),
                    ),
                  ),
                Text(
                  title,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : ThemeColors.textDark,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 12),
                if (isCompleted)
                  Row(
                    children: [
                      const Icon(LucideIcons.sparkles, color: ThemeColors.burgundy, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'CERTIFICATE EARNED',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: ThemeColors.burgundy,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'PROGRESS',
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: ThemeColors.burgundy,
                            ),
                          ),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : ThemeColors.textDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF0EAE6),
                          valueColor: const AlwaysStoppedAnimation<Color>(ThemeColors.burgundy),
                          minHeight: 4,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
