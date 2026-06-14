import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:art_mobile/core/routing/app_routes.dart';
import 'presentation/bloc/splash_bloc.dart';

/// [SplashScreen] implementation based on the high-fidelity React design.
/// Features a premium purple gradient, animated glassmorphism logo, 
/// and decorative floating blobs.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SplashBloc()..add(StartSplashTimer()),
      child: BlocListener<SplashBloc, SplashState>(
        listener: (context, state) {
          if (state is SplashCompleted) {
            // Navigate to home or welcome screen after the 2800ms sequence
            if (state.isLoggedIn) {
              Navigator.pushReplacementNamed(context, AppRoutes.home);
            } else {
              Navigator.pushReplacementNamed(context, AppRoutes.welcome);
            }
          }
        },
        child: const SplashView(),
      ),
    );
  }
}

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with TickerProviderStateMixin {
  // Animation controllers for various UI elements
  late AnimationController _blobController;
  late AnimationController _logoController;
  late AnimationController _dotsController;
  late AnimationController _lineController;

  @override
  void initState() {
    super.initState();
    
    // 1. Blob breathing animation (looping)
    _blobController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    // 2. Logo entrance spring-like animation
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // 3. Gold line expansion
    _lineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // 4. Loading dots pulsing (looping)
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    // Sequence the animations
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _logoController.forward();
    });
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) _lineController.forward();
    });
  }

  @override
  void dispose() {
    _blobController.dispose();
    _logoController.dispose();
    _dotsController.dispose();
    _lineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ---------------------------------------------------------
          // 1. PREMIUM GRADIENT BACKGROUND
          // ---------------------------------------------------------
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 0.5, 1.0],
                colors: [
                  Color(0xFF4A0072), // Dark Purple
                  Color(0xFF6A1B9A), // Medium Purple
                  Color(0xFFAB47BC), // Light Magenta
                ],
              ),
            ),
          ),

          // ---------------------------------------------------------
          // 2. DECORATIVE BLOBS (Animated)
          // ---------------------------------------------------------
          // Top-Right Blob
          Positioned(
            top: -80,
            right: -80,
            child: AnimatedBuilder(
              animation: _blobController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_blobController.value * 0.15),
                  child: Opacity(
                    opacity: 0.15 + (_blobController.value * 0.1),
                    child: child,
                  ),
                );
              },
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC107).withOpacity(0.3), // Gold blob
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),

          // Bottom-Left Blob
          Positioned(
            bottom: -60,
            left: -60,
            child: AnimatedBuilder(
              animation: _blobController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + ((1.0 - _blobController.value) * 0.2),
                  child: Opacity(
                    opacity: 0.1 + ((1.0 - _blobController.value) * 0.1),
                    child: child,
                  ),
                );
              },
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),

          // ---------------------------------------------------------
          // 3. MAIN LOGO AREA
          // ---------------------------------------------------------
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Glassmorphism Icon
                ScaleTransition(
                  scale: CurvedAnimation(
                    parent: _logoController,
                    curve: Curves.elasticOut,
                  ),
                  child: FadeTransition(
                    opacity: _logoController,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 40,
                            offset: const Offset(0, 20),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: const Center(
                            child: Text(
                              '🪡',
                              style: TextStyle(fontSize: 52),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Branding Text
                FadeTransition(
                  opacity: _logoController,
                  child: Column(
                    children: [
                      Text(
                        'AariLearn',
                        style: GoogleFonts.outfit(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'MASTER THE ART',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.75),
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // ---------------------------------------------------------
                // 4. GOLD ACCENT LINE (Animated Width)
                // ---------------------------------------------------------
                const SizedBox(height: 32),
                AnimatedBuilder(
                  animation: _lineController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _lineController.value,
                      child: Container(
                        width: 60 * _lineController.value,
                        height: 3,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC107), // Gold
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  },
                ),

                // ---------------------------------------------------------
                // 5. LOADING DOTS (Animated)
                // ---------------------------------------------------------
                const SizedBox(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    return AnimatedBuilder(
                      animation: _dotsController,
                      builder: (context, child) {
                        // Offset each dot's pulse
                        double value = (_dotsController.value + (i * 0.2)) % 1.0;
                        double scale = 0.8 + (Curves.easeInOut.transform(value) * 0.4);
                        double opacity = 0.25 + (Curves.easeInOut.transform(value) * 0.75);

                        return Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: i == 1 
                                ? const Color(0xFFFFC107).withOpacity(opacity) 
                                : Colors.white.withOpacity(opacity * 0.6),
                            shape: BoxShape.circle,
                          ),
                          child: Transform.scale(
                            scale: scale,
                            child: child,
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),

          // ---------------------------------------------------------
          // 6. BOTTOM TAGLINE
          // ---------------------------------------------------------
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _logoController, // Sync with logo entrance
              child: Center(
                child: Text(
                  'Crafted with ♥ for Indian Artisans',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.5),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
