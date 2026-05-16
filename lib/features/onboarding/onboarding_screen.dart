import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:art_mobile/core/routing/app_routes.dart';
import 'presentation/bloc/onboarding_bloc.dart';

/// [OnboardingScreen] implementation featuring high-fidelity animations,
/// dynamic background transitions, and glassmorphism elements.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OnboardingBloc()..add(LoadOnboardingSlides()),
      child: BlocListener<OnboardingBloc, OnboardingState>(
        listener: (context, state) {
          if (state.isCompleted) {
            Navigator.pushReplacementNamed(context, AppRoutes.skillSelection);
          }
        },
        child: const OnboardingView(),
      ),
    );
  }
}

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _blobController;
  late AnimationController _contentEntranceController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _blobController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
    _contentEntranceController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _contentEntranceController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _blobController.dispose();
    _contentEntranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<OnboardingBloc, OnboardingState>(
        builder: (context, state) {
          if (state.slides.isEmpty) return const SizedBox.shrink();

          final currentSlide = state.slides[state.currentIndex];

          return Stack(
            children: [
              // 1. ANIMATED BACKGROUND GRADIENT
              _buildAnimatedBackground(currentSlide),

              // 2. TOP BAR (Back & Skip)
              _buildTopBar(context, state),

              // 3. MAIN CONTENT (Emoji, Stats, Content, CTAs)
              Column(
                children: [
                  const SizedBox(height: 100),
                  // Illustration Section
                  _buildIllustration(currentSlide),
                  
                  const SizedBox(height: 32),
                  
                  // Wave Transition
                  RepaintBoundary(
                    child: SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: CustomPaint(painter: OnboardingWavePainter(color: Colors.white)),
                    ),
                  ),

                  // Content Section
                  Expanded(
                    child: _buildContentArea(context, state, currentSlide),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAnimatedBackground(OnboardingSlide slide) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      height: 380,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: slide.gradientColors.map((c) => Color(c)).toList(),
        ),
      ),
      child: Stack(
        children: [
          // Decorative Blobs (Isolated in RepaintBoundary for performance)
          Positioned(
            top: -60,
            right: -40,
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _blobController,
                builder: (context, child) => Transform.scale(
                  scale: 1.0 + (_blobController.value * 0.3),
                  child: Opacity(opacity: 0.1 + (_blobController.value * 0.1), child: child),
                ),
                child: Container(width: 200, height: 200, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: -20,
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _blobController,
                builder: (context, child) => Transform.scale(
                  scale: 1.0 + ((1.0 - _blobController.value) * 0.2),
                  child: Opacity(opacity: 0.1, child: child),
                ),
                child: Container(width: 140, height: 140, decoration: BoxDecoration(color: Color(slide.accentColor), shape: BoxShape.circle)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, OnboardingState state) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                if (state.currentIndex > 0) {
                  context.read<OnboardingBloc>().add(PreviousSlidePressed());
                } else {
                  Navigator.pop(context);
                }
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                child: const Icon(LucideIcons.chevronLeft, color: Colors.white, size: 20),
              ),
            ),
            TextButton(
              onPressed: () => context.read<OnboardingBloc>().add(SkipPressed()),
              child: Text(
                'Skip',
                style: GoogleFonts.outfit(fontSize: 13, color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIllustration(OnboardingSlide slide) {
    return Column(
      children: [
        // Glassmorphism Emoji Box (Isolated for elastic animations)
        RepaintBoundary(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: CurvedAnimation(parent: animation, curve: Curves.elasticOut),
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: Container(
              key: ValueKey('emoji-${slide.id}'),
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 48, offset: const Offset(0, 16))],
              ),
              alignment: Alignment.center,
              child: Text(slide.emoji, style: const TextStyle(fontSize: 56)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Stats Pills
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: slide.stats.asMap().entries.map((entry) {
            final i = entry.key;
            final stat = entry.value;
            return FadeTransition(
              opacity: _contentEntranceController,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
                  CurvedAnimation(parent: _contentEntranceController, curve: Interval(i * 0.1, 1.0, curve: Curves.easeOut)),
                ),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.25)),
                  ),
                  child: Column(
                    children: [
                      Text(stat.value, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white, height: 1)),
                      Text(stat.label, style: GoogleFonts.outfit(fontSize: 9, color: Colors.white.withOpacity(0.75))),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildContentArea(BuildContext context, OnboardingState state, OnboardingSlide slide) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Slide Content (Text)
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) => SlideTransition(
                position: Tween<Offset>(begin: const Offset(0.1, 0), end: Offset.zero).animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: Column(
                key: ValueKey('content-${slide.id}'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slide.subtitle.toUpperCase(),
                    style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700, color: Color(slide.gradientColors[1]), letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    slide.title,
                    style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w800, color: const Color(0xFF212121), height: 1.2),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    slide.description,
                    style: GoogleFonts.outfit(fontSize: 14, color: const Color(0xFF757575), height: 1.7),
                  ),
                ],
              ),
            ),
          ),

          // Indicators (Dots)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: state.slides.asMap().entries.map((entry) {
              final i = entry.key;
              final isActive = i == state.currentIndex;
              return GestureDetector(
                onTap: () => context.read<OnboardingBloc>().add(SetSlideIndex(i)),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 28 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive ? Color(slide.gradientColors[1]) : const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 32),

          // CTA Button
          GestureDetector(
            onTap: () => context.read<OnboardingBloc>().add(NextSlidePressed()),
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: slide.gradientColors.map((c) => Color(c)).toList()),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Color(slide.gradientColors[1]).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.currentIndex == state.slides.length - 1 ? 'Choose Your Level' : 'Next',
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  const Icon(LucideIcons.arrowRight, color: Colors.white, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingWavePainter extends CustomPainter {
  final Color color;
  OnboardingWavePainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    // M0 30 Q97.5 0 195 25 Q292.5 50 390 20 L390 50 L0 50 Z
    path.moveTo(0, size.height * 0.6);
    path.quadraticBezierTo(size.width * 0.25, 0, size.width * 0.5, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.75, size.height, size.width, size.height * 0.4);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
