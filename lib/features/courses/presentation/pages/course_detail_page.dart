import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:art_mobile/core/config/service_locator.dart';
import 'package:art_mobile/core/routing/app_routes.dart';
import 'package:art_mobile/core/storage/secure_storage_service.dart';
import 'package:art_mobile/core/theme/theme_colors.dart';
import 'package:art_mobile/core/theme/theme_manager.dart';
import 'package:art_mobile/features/auth/data/models/auth_models.dart';
import 'package:art_mobile/features/payment/services/razorpay_service.dart';
import 'package:art_mobile/features/video_player/data/video_progress_service.dart';
import '../../data/models/course_model.dart';
import '../../domain/repositories/course_repository.dart';
import '../bloc/course_detail/course_detail_bloc.dart';

class CourseDetailPage extends StatelessWidget {
  final String courseId;

  const CourseDetailPage({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CourseDetailBloc(sl<ICourseRepository>())..add(LoadCourseDetail(courseId)),
      child: const CourseDetailView(),
    );
  }
}

class CourseDetailView extends StatefulWidget {
  const CourseDetailView({super.key});

  @override
  State<CourseDetailView> createState() => _CourseDetailViewState();
}

class _CourseDetailViewState extends State<CourseDetailView> with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late RazorpayService _razorpayService;
  bool _enrollLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();

    // Setup Razorpay
    _razorpayService = sl<RazorpayService>();
    _razorpayService.onSuccess = _handlePaymentSuccess;
    _razorpayService.onFailure = _handlePaymentFailure;
    _razorpayService.onExternalWallet = _handleExternalWallet;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    _razorpayService.dispose();
    super.dispose();
  }

  // ─── Razorpay callbacks ───────────────────────────────────────────────────

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    setState(() => _enrollLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF10B981),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Payment successful! Payment ID: ${response.paymentId}',
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    final state = context.read<CourseDetailBloc>().state;
    if (state is CourseDetailLoaded) {
      final firstSection = state.course.curriculum.isNotEmpty ? state.course.curriculum.first : null;
      final firstLesson = firstSection?.lessons.isNotEmpty == true ? firstSection!.lessons.first : null;
      
      if (firstLesson != null && firstLesson.videoUrl.isNotEmpty) {
        Future.delayed(const Duration(seconds: 1), () {
          if (!mounted) return;
          Navigator.pushNamed(
            context,
            AppRoutes.videoPlayer,
            arguments: {
              'courseId': state.course.id,
              'videoId': firstLesson.id,
              'videoUrl': firstLesson.videoUrl,
            },
          ).then((_) => setState(() {}));
        });
      }
    }
  }

  void _handlePaymentFailure(PaymentFailureResponse response) {
    setState(() => _enrollLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFFEF4444),
        content: Row(
          children: [
            const Icon(Icons.error_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                response.message ?? 'Payment failed. Please try again.',
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() => _enrollLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('External wallet selected: ${response.walletName}',
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 13)),
        backgroundColor: const Color(0xFF6A1B9A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _startEnrollment(CourseDetail course) async {
    setState(() => _enrollLoading = true);
    try {
      final userDataJson = await sl<SecureStorageService>().getUserData();
      final userData = UserData.fromJsonString(userDataJson);
      _razorpayService.openCheckout(
        amountInRupees: course.price.toDouble(),
        courseName: course.title,
        userPhone: userData?.phone ?? '',
        userEmail: userData?.email,
        userId: userData?.id,
      );
    } catch (e) {
      setState(() => _enrollLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = sl<ThemeManager>().isDarkMode;
    return Scaffold(
      backgroundColor: isDark ? ThemeColors.backgroundDark : Colors.white,
      body: SafeArea(
        child: BlocBuilder<CourseDetailBloc, CourseDetailState>(
          builder: (context, state) {
            if (state is CourseDetailLoading) {
              return Center(child: CircularProgressIndicator(color: isDark ? ThemeColors.burgundyLight : const Color(0xFF6A1B9A)));
            }
  
            if (state is CourseDetailLoaded) {
              return _buildMainContent(context, state, isDark);
            }
  
            if (state is CourseDetailError) {
              return Column(
                children: [
                  // Back button so user is never stuck
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline_rounded, color: Colors.grey, size: 48),
                            const SizedBox(height: 16),
                            Text(
                              'Could not load course',
                              style: GoogleFonts.outfit(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              state.message,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () => context.read<CourseDetailBloc>().add(
                                    LoadCourseDetail(
                                      (context.read<CourseDetailBloc>().state as CourseDetailError?)
                                              ?.message ??
                                          '1',
                                    ),
                                  ),
                              icon: const Icon(Icons.refresh),
                              label: Text('Retry', style: GoogleFonts.outfit()),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6A1B9A),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
  
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, CourseDetailLoaded state, bool isDark) {
    final course = state.course;
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(child: _buildVideoHeader(context, state)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildCategoryBadges(course, isDark),
                    const SizedBox(height: 16),
                    Text(
                      course.title,
                      style: GoogleFonts.outfit(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildStatsRow(course, isDark),
                    const SizedBox(height: 24),
                    _buildInstructorCard(course, isDark),
                    const SizedBox(height: 24),
                    _buildFeaturesGrid(course, isDark),
                    const SizedBox(height: 24),
                    _buildPricingCard(context, course, isDark),
                    const SizedBox(height: 32),
                    _buildTabs(context, state, isDark),
                    const SizedBox(height: 24),
                    _buildTabContent(context, state, isDark),
                    const SizedBox(height: 120),
                  ]),
                ),
              ),
            ],
          ),
          _buildStickyFooter(context, course, isDark),
        ],
      ),
    );
  }

  Widget _buildVideoHeader(BuildContext context, CourseDetailLoaded state) {
    CourseLesson? previewLesson;
    for (final section in state.course.curriculum) {
      for (final lesson in section.lessons) {
        if (lesson.videoUrl.isNotEmpty) {
          previewLesson = lesson;
          break;
        }
      }
      if (previewLesson != null) break;
    }

    final videoUrl = previewLesson?.videoUrl ?? state.course.videoUrl;
    final videoId = previewLesson?.id ?? state.course.id;

    return Container(
      height: 260,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        image: DecorationImage(
          image: state.course.image.startsWith('http')
              ? NetworkImage(state.course.image)
              : AssetImage(state.course.image) as ImageProvider,
          fit: BoxFit.cover,
          opacity: 0.7,
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCircleButton(LucideIcons.arrowLeft, () => Navigator.pop(context)),
                Row(
                  children: [
                    _buildCircleButton(
                      LucideIcons.heart, 
                      () => context.read<CourseDetailBloc>().add(ToggleWishlist()),
                      fillColor: state.isWishlisted ? const Color(0xFFEF5350) : null,
                      iconColor: Colors.white,
                    ),
                    const SizedBox(width: 12),
                    _buildCircleButton(LucideIcons.share2, () {}),
                  ],
                ),
              ],
            ),
          ),
          Center(
            child: GestureDetector(
              onTap: videoUrl.isEmpty
                  ? null
                  : () => Navigator.pushNamed(
                        context,
                        AppRoutes.videoPlayer,
                        arguments: {
                          'courseId': state.course.id,
                          'videoId': videoId,
                          'videoUrl': videoUrl,
                        },
                      ).then((_) => setState(() {})),
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF6A1B9A).withOpacity(0.9),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.6), width: 3),
                ),
                child: const Icon(LucideIcons.play, color: Colors.white, size: 28),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onTap, {Color? fillColor, Color? iconColor}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(color: fillColor ?? Colors.black.withOpacity(0.3), shape: BoxShape.circle),
        child: Icon(icon, color: iconColor ?? Colors.white, size: 20),
      ),
    );
  }

  Widget _buildCategoryBadges(CourseDetail course, bool isDark) {
    return Row(
      children: [
        _buildBadge(course.category, const Color(0xFF6A1B9A).withOpacity(0.1), const Color(0xFF6A1B9A)),
        const SizedBox(width: 8),
        _buildBadge(course.level, const Color(0xFFFFC107).withOpacity(0.15), const Color(0xFFF57F17)),
      ],
    );
  }

  Widget _buildBadge(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
      child: Text(label, style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: textColor)),
    );
  }

  Widget _buildStatsRow(CourseDetail course, bool isDark) {
    return Row(
      children: [
        _buildStatItem(LucideIcons.star, course.rating.toString(), isDark, isGold: true),
        _buildDotDivider(isDark),
        _buildStatItem(LucideIcons.users, '${(course.students / 1000).toStringAsFixed(1)}k learners', isDark),
        _buildDotDivider(isDark),
        _buildStatItem(LucideIcons.clock, course.duration, isDark),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String label, bool isDark, {bool isGold = false}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: isGold ? const Color(0xFFFFC107) : Colors.grey.shade500),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: isGold ? FontWeight.bold : FontWeight.w500,
            color: isGold ? (isDark ? const Color(0xFFFFD54F) : const Color(0xFF1A1A1A)) : Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildDotDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(width: 4, height: 4, decoration: BoxDecoration(color: isDark ? Colors.white24 : Colors.grey.shade300, shape: BoxShape.circle)),
    );
  }

  Widget _buildInstructorCard(CourseDetail course, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? ThemeColors.surfaceDark : const Color(0xFFF8F6FB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? ThemeColors.borderDark : Colors.transparent),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF6A1B9A), Color(0xFFAB47BC)]),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(course.instructor[0], style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(course.instructor, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
                Text(course.instructorRole, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
          ),
          Icon(LucideIcons.chevronRight, size: 18, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  Widget _buildFeaturesGrid(CourseDetail course, bool isDark) {
    return Row(
      children: [
        _buildFeatureItem(LucideIcons.bookOpen, '${course.lessonCount}', 'Lessons', isDark),
        const SizedBox(width: 12),
        _buildFeatureItem(LucideIcons.clock, course.duration, 'Content', isDark),
        const SizedBox(width: 12),
        _buildFeatureItem(LucideIcons.award, 'Certify', 'Included', isDark),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String label, String sub, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.03) : const Color(0xFFF8F6FB),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? ThemeColors.borderDark : Colors.transparent),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF6A1B9A), size: 22),
            const SizedBox(height: 8),
            Text(label, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
            Text(sub, style: GoogleFonts.outfit(fontSize: 10, color: Colors.grey.shade500, letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingCard(BuildContext context, CourseDetail course, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark 
            ? [const Color(0xFF6A1B9A).withOpacity(0.15), const Color(0xFFAB47BC).withOpacity(0.15)]
            : [const Color(0xFF6A1B9A).withOpacity(0.06), const Color(0xFFAB47BC).withOpacity(0.06)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: isDark ? const Color(0xFF6A1B9A).withOpacity(0.3) : Colors.transparent),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Enroll now and save', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade500)),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text('₹${course.price}', style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w800, color: isDark ? const Color(0xFFE1BEE7) : const Color(0xFF6A1B9A))),
                      const SizedBox(width: 10),
                      Text('₹${course.originalPrice}', style: GoogleFonts.outfit(fontSize: 16, color: Colors.grey.shade500, decoration: TextDecoration.lineThrough)),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFFFC107), borderRadius: BorderRadius.circular(12)),
                child: Text('LIMITED TIME', style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.subscription),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF6A1B9A).withOpacity(0.3))),
              child: Row(
                children: [
                  const Icon(LucideIcons.zap, size: 16, color: Color(0xFFFFC107)),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Get all courses for ₹499/mo', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF6A1B9A)))),
                  const Icon(LucideIcons.arrowRight, size: 14, color: Color(0xFF6A1B9A)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(BuildContext context, CourseDetailLoaded state, bool isDark) {
    final tabs = ['OVERVIEW', 'CURRICULUM', 'REVIEWS'];
    return Row(
      children: List.generate(tabs.length, (index) {
        final isActive = state.activeTab == index;
        return Expanded(
          child: GestureDetector(
            onTap: () => context.read<CourseDetailBloc>().add(SelectTab(index)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: isActive ? const Color(0xFF6A1B9A) : (isDark ? Colors.white12 : Colors.grey.shade100), width: 3)),
              ),
              alignment: Alignment.center,
              child: Text(
                tabs[index],
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color: isActive ? const Color(0xFF6A1B9A) : Colors.grey.shade500,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTabContent(BuildContext context, CourseDetailLoaded state, bool isDark) {
    switch (state.activeTab) {
      case 0: return _buildOverview(state.course, isDark);
      case 1: return _buildCurriculum(context, state, isDark);
      case 2: return _buildReviews(state.course, isDark);
      default: return const SizedBox.shrink();
    }
  }

  Widget _buildOverview(CourseDetail course, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(course.description, style: GoogleFonts.outfit(fontSize: 15, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, height: 1.6)),
        const SizedBox(height: 32),
        Text('Learning Outcomes', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
        const SizedBox(height: 16),
        ...['Master intricate stitch patterns', 'Understand advanced color theory', 'Professional finishing techniques'].map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              const Icon(LucideIcons.checkCircle2, color: Color(0xFF6A1B9A), size: 18),
              const SizedBox(width: 12),
              Expanded(child: Text(item, style: GoogleFonts.outfit(fontSize: 14, color: isDark ? Colors.grey.shade300 : const Color(0xFF1A1A1A)))),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildCurriculum(BuildContext context, CourseDetailLoaded state, bool isDark) {
    final completedLessons = sl<VideoProgressService>().getCompletedLessons(state.course.id);
    return Column(
      children: state.course.curriculum.map((section) {
        final isExpanded = state.expandedSections.contains(section.id);
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDark ? ThemeColors.borderDark : const Color(0xFF6A1B9A).withOpacity(0.1)),
          ),
          child: Column(
            children: [
              GestureDetector(
                onTap: () => context.read<CourseDetailBloc>().add(ToggleSection(section.id)),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? ThemeColors.surfaceDark : const Color(0xFFF8F6FB),
                    borderRadius: BorderRadius.vertical(top: const Radius.circular(20), bottom: isExpanded ? Radius.zero : const Radius.circular(20)),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: Text(section.title, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A1A1A)))),
                      Icon(isExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown, color: const Color(0xFF6A1B9A), size: 20),
                    ],
                  ),
                ),
              ),
              if (isExpanded)
                Column(
                  children: section.lessons.map((lesson) => GestureDetector(
                    onTap: lesson.videoUrl.isEmpty
                        ? null
                        : () => Navigator.pushNamed(
                              context,
                              AppRoutes.videoPlayer,
                              arguments: {
                                'courseId': state.course.id,
                                'videoId': lesson.id,
                                'videoUrl': lesson.videoUrl,
                              },
                            ).then((_) => setState(() {})),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade100))),
                      child: Row(
                        children: [
                          Icon(completedLessons.contains(lesson.id) ? LucideIcons.checkCircle2 : LucideIcons.playCircle, color: const Color(0xFF6A1B9A), size: 18),
                          const SizedBox(width: 12),
                          Expanded(child: Text(lesson.title, style: GoogleFonts.outfit(fontSize: 14, color: isDark ? Colors.grey.shade300 : const Color(0xFF1A1A1A)))),
                          Text(lesson.duration, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade500)),
                        ],
                      ),
                    ),
                  )).toList(),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReviews(CourseDetail course, bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: isDark ? ThemeColors.surfaceDark : const Color(0xFFF8F6FB), borderRadius: BorderRadius.circular(24)),
          child: Row(
            children: [
              Column(
                children: [
                  Text(course.rating.toString(), style: GoogleFonts.outfit(fontSize: 44, fontWeight: FontWeight.w800, color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
                  Row(children: List.generate(5, (i) => Icon(LucideIcons.star, size: 12, color: i < 4 ? const Color(0xFFFFC107) : Colors.grey.shade300, fill: i < 4 ? 1 : 0))),
                  const SizedBox(height: 6),
                  Text('${course.reviews} reviews', style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey.shade500)),
                ],
              ),
              const SizedBox(width: 32),
              Expanded(
                child: Column(
                  children: List.generate(5, (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Text('${5-i}', style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey.shade500)),
                        const SizedBox(width: 12),
                        Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(3), child: LinearProgressIndicator(value: i == 0 ? 0.8 : 0.1, minHeight: 6, backgroundColor: isDark ? Colors.white10 : Colors.grey.shade200, valueColor: const AlwaysStoppedAnimation(Color(0xFFFFC107))))),
                      ],
                    ),
                  )),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        ...course.reviewsList.map((review) => Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(radius: 18, backgroundColor: const Color(0xFF6A1B9A), child: Text(review.avatar, style: const TextStyle(color: Colors.white, fontSize: 12))),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(review.name, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
                    Text(review.date, style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey.shade500)),
                  ]),
                ],
              ),
              const SizedBox(height: 12),
              Text(review.comment, style: GoogleFonts.outfit(fontSize: 14, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, height: 1.5)),
              const SizedBox(height: 16),
              Divider(color: isDark ? Colors.white10 : Colors.grey.shade100),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildStickyFooter(BuildContext context, CourseDetail course, bool isDark) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: isDark ? ThemeColors.backgroundDark : Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -4))],
          border: Border(top: BorderSide(color: isDark ? ThemeColors.borderDark : Colors.grey.shade100)),
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Price', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade500)),
                Text('₹${course.price}', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFF6A1B9A))),
              ],
            ),
            const SizedBox(width: 24),
            Expanded(
              child: ElevatedButton(
                onPressed: _enrollLoading ? null : () => _startEnrollment(course),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A1B9A),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFF6A1B9A).withOpacity(0.6),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _enrollLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text('ENROLL NOW', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
