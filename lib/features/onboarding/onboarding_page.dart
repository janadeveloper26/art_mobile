import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme_colors.dart';

class OnboardingPage extends StatefulWidget {
  final String imagePath;
  final String title;
  final String description;
  final String currentPage;
  final int totalPages;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const OnboardingPage({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
    required this.currentPage,
    required this.totalPages,
    required this.onNext,
    required this.onSkip,
  });

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Stack(
      children: [
        // Background Image with Gradient
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: size.height * 0.55,
          child: Stack(
            children: [
              Image.asset(
                widget.imagePath,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      ThemeColors.backgroundLight.withOpacity(0.5),
                      ThemeColors.backgroundLight,
                    ],
                    stops: const [0.6, 0.85, 1.0],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Header (Logo and Close)
        Positioned(
          top: MediaQuery.of(context).padding.top + 20,
          left: 24,
          right: 24,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ATELIER',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: ThemeColors.burgundy,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: ThemeColors.burgundy, size: 28),
                onPressed: widget.onSkip,
              ),
            ],
          ),
        ),

        // Content
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: size.height * 0.5,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const Spacer(flex: 1),
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                    color: ThemeColors.textDark,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  widget.description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    color: ThemeColors.textSecondary,
                    height: 1.6,
                  ),
                ),
                const Spacer(flex: 2),
                
                // Page Indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.totalPages,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: index == int.parse(widget.currentPage) ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: index == int.parse(widget.currentPage) 
                          ? ThemeColors.burgundy 
                          : ThemeColors.burgundy.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
                
                const Spacer(flex: 2),
                
                // Primary Action Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: widget.onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeColors.burgundy,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'NEXT',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Bottom Navigation
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: ThemeColors.burgundyLight),
                      onPressed: () {
                        // Handle back
                      },
                    ),
                    TextButton(
                      onPressed: widget.onSkip,
                      child: Text(
                        'SKIP FOR NOW',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: ThemeColors.textSecondary,
                        ),
                      ),
                    ),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: ThemeColors.burgundyDark,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_forward, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
          ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
