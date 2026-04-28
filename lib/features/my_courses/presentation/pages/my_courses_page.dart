import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:art_mobile/core/config/service_locator.dart';
import 'package:art_mobile/core/routing/app_routes.dart';
import 'package:art_mobile/core/theme/theme_colors.dart';
import 'package:art_mobile/core/theme/theme_manager.dart';
import '../bloc/my_courses_bloc.dart';
import '../../data/models/my_courses_model.dart';
import '../../../courses/data/models/course_model.dart';

class MyCoursesPage extends StatelessWidget {
  const MyCoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MyCoursesBloc(sl())..add(LoadMyCourses()),
      child: const MyCoursesView(),
    );
  }
}

class MyCoursesView extends StatefulWidget {
  const MyCoursesView({super.key});

  @override
  State<MyCoursesView> createState() => _MyCoursesViewState();
}

class _MyCoursesViewState extends State<MyCoursesView> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: sl<ThemeManager>(),
      builder: (context, _) {
        final isDark = sl<ThemeManager>().isDarkMode;
        return Scaffold(
          backgroundColor: isDark ? ThemeColors.backgroundDark : const Color(0xFFFBFBFB),
          body: SafeArea(
            child: BlocBuilder<MyCoursesBloc, MyCoursesState>(
              builder: (context, state) {
                if (state is MyCoursesLoading) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF6A1B9A)));
                }

                if (state is MyCoursesLoaded) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
                          child: Text(
                            'Dashboard',
                            style: GoogleFonts.outfit(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'Track your creative growth',
                            style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey.shade500),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Stats Bar
                        _buildStatsBar(state.data, isDark),
                        const SizedBox(height: 32),

                        // Tabs
                        _buildTabs(context, state, isDark),
                        const SizedBox(height: 20),

                        // Course List
                        Expanded(
                          child: _buildCourseList(context, state, isDark),
                        ),
                      ],
                    ),
                  );
                }

                if (state is MyCoursesError) {
                  return Center(child: Text(state.message));
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsBar(MyCoursesResponse data, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A1B9A), Color(0xFFAB47BC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6A1B9A).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStatItem('Enrolled', data.totalEnrolled.toString(), true),
          _buildStatItem('Ongoing', data.ongoing.length.toString(), true),
          _buildStatItem('Completed', data.completed.length.toString(), true),
          _buildStatItem('Awards', data.totalCertificates.toString(), false),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, bool hasDivider) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: hasDivider ? Border(right: BorderSide(color: Colors.white.withOpacity(0.15))) : null,
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.8), letterSpacing: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs(BuildContext context, MyCoursesLoaded state, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isDark ? ThemeColors.surfaceDark : const Color(0xFFF0EDF5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _buildTabItem(context, 'In Progress', 0, state.activeTab == 0, isDark),
          _buildTabItem(context, 'Completed', 1, state.activeTab == 1, isDark),
        ],
      ),
    );
  }

  Widget _buildTabItem(BuildContext context, String label, int index, bool isActive, bool isDark) {
    return Expanded(
      child: GestureDetector(
        onTap: () => context.read<MyCoursesBloc>().add(ToggleTab(index)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isActive ? (isDark ? const Color(0xFFAB47BC) : const Color(0xFF6A1B9A)) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isActive ? [
              BoxShadow(
                color: const Color(0xFF6A1B9A).withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ] : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : Colors.grey.shade500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCourseList(BuildContext context, MyCoursesLoaded state, bool isDark) {
    final courses = state.activeTab == 0 ? state.data.ongoing : state.data.completed;

    if (courses.isEmpty) {
      return _buildEmptyState(context, state.activeTab == 0, isDark);
    }

    return ListView.builder(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 40),
      physics: const BouncingScrollPhysics(),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        return _buildCourseCard(context, course, state.activeTab == 0, isDark);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isOngoing, bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: isDark ? ThemeColors.surfaceDark : const Color(0xFFF8F6FB),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(
            isOngoing ? LucideIcons.bookOpen : LucideIcons.award, 
            size: 32, 
            color: const Color(0xFF6A1B9A).withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          isOngoing ? 'No active courses' : 'No accomplishments yet',
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
        ),
        const SizedBox(height: 8),
        Text(
          isOngoing ? 'Pick up where you left off by enrolling' : 'Your earned certificates will appear here',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.courses),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6A1B9A),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: Text(
            'Discover New Skills',
            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildCourseCard(BuildContext context, CourseSummary course, bool isOngoing, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isDark ? ThemeColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: isDark ? ThemeColors.borderDark : Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Thumbnail
                Stack(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(image: AssetImage(course.image), fit: BoxFit.cover),
                      ),
                    ),
                    if (!isOngoing)
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6A1B9A).withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(LucideIcons.award, color: Color(0xFFFFC107), size: 36),
                      ),
                  ],
                ),
                const SizedBox(width: 20),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        course.instructor,
                        style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade500),
                      ),
                      const SizedBox(height: 14),
                      if (isOngoing) ...[
                        _buildProgressBar(course.progress ?? 0),
                        const SizedBox(height: 8),
                        Text(
                          '${((course.progress ?? 0) * 100).toInt()}% COMPLETE',
                          style: GoogleFonts.outfit(
                            fontSize: 10, 
                            fontWeight: FontWeight.w800, 
                            color: const Color(0xFF6A1B9A),
                            letterSpacing: 1,
                          ),
                        ),
                      ] else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF9C4).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(LucideIcons.award, size: 12, color: Color(0xFFF57F17)),
                              const SizedBox(width: 6),
                              Text(
                                'PASSED',
                                style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFFF57F17)),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Actions
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: isDark ? ThemeColors.borderDark : const Color(0xFF6A1B9A).withOpacity(0.06))),
            ),
            child: Row(
              children: [
                if (isOngoing) ...[
                  Expanded(
                    child: _buildActionButton(
                      'RESUME', 
                      const Color(0xFF6A1B9A), 
                      Colors.white, 
                      LucideIcons.playCircle,
                      () => Navigator.pushNamed(context, AppRoutes.videoPlayer, arguments: {'videoId': 'l4'}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildSecondaryButton('DETAILS', () => Navigator.pushNamed(context, AppRoutes.courseDetail, arguments: {'courseId': course.id})),
                ] else ...[
                  Expanded(
                    child: _buildActionButton(
                      'CERTIFICATE', 
                      const Color(0xFF6A1B9A).withOpacity(0.05), 
                      const Color(0xFF6A1B9A), 
                      LucideIcons.award,
                      () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildSecondaryButton('REVIEW', () => Navigator.pushNamed(context, AppRoutes.courseDetail, arguments: {'courseId': course.id})),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double progress) {
    return Container(
      height: 8,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF0E5F5), 
        borderRadius: BorderRadius.circular(4),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF6A1B9A), Color(0xFFAB47BC)]),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, Color bgColor, Color textColor, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 16),
            const SizedBox(width: 10),
            Text(label, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w800, color: textColor, letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: const Color(0xFF6A1B9A).withOpacity(0.2), width: 1.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF6A1B9A), letterSpacing: 0.5),
        ),
      ),
    );
  }
}
