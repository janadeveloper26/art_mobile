import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:art_mobile/core/routing/app_routes.dart';
import 'package:art_mobile/core/theme/theme_manager.dart';
import 'package:art_mobile/core/config/service_locator.dart';
import 'package:art_mobile/core/theme/theme_colors.dart';
import '../bloc/welcome_bloc.dart';

/// [WelcomeScreen] provides a high-fidelity introduction to the app.
/// Optimized for a single-screen layout with no scrolling.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WelcomeBloc(),
      child: BlocListener<WelcomeBloc, WelcomeState>(
        listener: (context, state) {
          if (state is NavigateToOnboarding) {
            Navigator.pushNamed(context, AppRoutes.onboarding);
          } else if (state is NavigateToLogin) {
            Navigator.pushNamed(context, AppRoutes.login);
          }
        },
        child: const WelcomeView(),
      ),
    );
  }
}

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _floatingController;
  late AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();
    _floatingController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _entranceController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _entranceController.forward();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _floatingController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final heroHeight = size.height * 0.48;

    return AnimatedBuilder(
      animation: sl<ThemeManager>(),
      builder: (context, _) {
        final isDark = sl<ThemeManager>().isDarkMode;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: isDark ? Colors.black : Colors.white,
            statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
            statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
            systemNavigationBarColor: isDark ? Colors.black : Colors.white,
            systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          ),
          child: Scaffold(
            backgroundColor: isDark ? ThemeColors.backgroundDark : Colors.white,
            body: Column(
              children: [
                // ---------------------------------------------------------
                // 1. HERO AREA
                // ---------------------------------------------------------
                Stack(
                  children: [
                    Container(
                      height: heroHeight,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF4A0072), Color(0xFF6A1B9A), Color(0xFFAB47BC)],
                          stops: [0.0, 0.45, 1.0],
                        ),
                      ),
                      child: Stack(
                        children: [
                          _buildRotatingCircle(240, -40, -40, _rotationController, 1.0),
                          _buildRotatingCircle(160, 40, 20, _rotationController, -1.2, color: const Color(0xFFFFC107).withOpacity(0.15)),
                          _buildHeroIllustration(size),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: -1,
                      left: 0,
                      right: 0,
                      child: RepaintBoundary(
                        child: SizedBox(
                          height: 40,
                          child: CustomPaint(painter: WavePainter(color: isDark ? ThemeColors.backgroundDark : Colors.white)),
                        ),
                      ),
                    ),
                  ],
                ),

                // ---------------------------------------------------------
                // 2. CONTENT AREA
                // ---------------------------------------------------------
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        
                        // Header & Description Group
                        FadeTransition(
                          opacity: _entranceController,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Learn Aari & ',
                                      style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w800, color: isDark ? Colors.white : const Color(0xFF212121), height: 1.1),
                                    ),
                                    TextSpan(
                                      text: 'Tailoring',
                                      style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w800, color: const Color(0xFF6A1B9A), height: 1.1),
                                    ),
                                    TextSpan(
                                      text: '\nfrom Experts',
                                      style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w800, color: isDark ? Colors.white : const Color(0xFF212121), height: 1.1),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Join thousands of learners mastering traditional Indian crafts with premium video courses.',
                                style: GoogleFonts.outfit(fontSize: 13, color: isDark ? Colors.white70 : const Color(0xFF757575), height: 1.5),
                              ),
                            ],
                          ),
                        ),

                        _buildHighlightsGrid(isDark),
                        _buildCTAButtons(context),

                        Center(
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: GoogleFonts.outfit(fontSize: 10, color: isDark ? Colors.white24 : const Color(0xFFBDBDBD)),
                              children: const [
                                TextSpan(text: 'By continuing you agree to our '),
                                TextSpan(text: 'Terms', style: TextStyle(color: Color(0xFF6A1B9A), fontWeight: FontWeight.bold)),
                                TextSpan(text: ' & '),
                                TextSpan(text: 'Privacy Policy', style: TextStyle(color: Color(0xFF6A1B9A), fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRotatingCircle(double size, double top, double right, AnimationController controller, double speedFactor, {Color? color}) {
    return Positioned(
      top: top,
      right: right,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, child) => Transform.rotate(angle: controller.value * 2.0 * math.pi * speedFactor, child: child),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: color ?? Colors.white.withOpacity(0.08), width: 2)),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroIllustration(Size size) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          // Main Emblem
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _floatingController,
              builder: (context, child) => Transform.translate(offset: Offset(0, 6 * math.sin(_floatingController.value * 2.0 * math.pi)), child: child),
              child: Container(
                width: size.width * 0.28,
                height: size.width * 0.28,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 30, offset: const Offset(0, 15))],
                ),
                alignment: Alignment.center,
                child: Text('🧵', style: TextStyle(fontSize: size.width * 0.14)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Badge Cards
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildBadgeCard('🪡', 'Aari', 0.5),
              const SizedBox(width: 8),
              _buildBadgeCard('✂️', 'Tailoring', 0.6),
              const SizedBox(width: 8),
              _buildBadgeCard('🌸', 'Embroidery', 0.7),
            ],
          ),
          const SizedBox(height: 20),
          // Play Preview
          ScaleTransition(
            scale: CurvedAnimation(parent: _entranceController, curve: const Interval(0.6, 1.0, curve: Curves.elasticOut)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFC107).withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 20, height: 20, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(LucideIcons.play, size: 10, color: Color(0xFFF57F17))),
                  const SizedBox(width: 6),
                  Text('Watch Preview', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF212121))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeCard(String emoji, String label, double delay) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _entranceController, curve: Interval(delay, 1.0)),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(CurvedAnimation(parent: _entranceController, curve: Interval(delay, 1.0, curve: Curves.easeOut))),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.2))),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 2),
              Text(label, style: GoogleFonts.outfit(fontSize: 9, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightsGrid(bool isDark) {
    final highlights = [
      {'emoji': '🎨', 'label': '100+ Courses'},
      {'emoji': '👩‍🏫', 'label': 'Expert Tutors'},
      {'emoji': '🏆', 'label': 'Certificates'},
      {'emoji': '📱', 'label': 'Offline Mode'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 3.2),
      itemCount: highlights.length,
      itemBuilder: (context, index) {
        final h = highlights[index];
        return FadeTransition(
          opacity: _entranceController,
          child: ScaleTransition(
            scale: CurvedAnimation(parent: _entranceController, curve: Interval(0.4 + (index * 0.08), 1.0, curve: Curves.easeOut)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF8F6FB), borderRadius: BorderRadius.circular(14)),
              child: Row(
                children: [
                  Text(h['emoji']!, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(h['label']!, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF212121))),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCTAButtons(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => context.read<WelcomeBloc>().add(GetStartedPressed()),
          child: Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF6A1B9A), Color(0xFFAB47BC)]),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: const Color(0xFF6A1B9A).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 6))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Get Started', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(width: 8),
                const Icon(LucideIcons.arrowRight, color: Colors.white, size: 16),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => context.read<WelcomeBloc>().add(AlreadyHaveAccountPressed()),
          child: Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF6A1B9A).withOpacity(0.3), width: 1.5)),
            alignment: Alignment.center,
            child: Text('I already have an account', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF6A1B9A))),
          ),
        ),
      ],
    );
  }
}

class WavePainter extends CustomPainter {
  final Color color;
  WavePainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    path.moveTo(0, size.height * 0.6);
    path.quadraticBezierTo(size.width * 0.25, 0, size.width * 0.5, size.height * 0.6);
    path.quadraticBezierTo(size.width * 0.75, size.height * 1.2, size.width, size.height * 0.6);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
