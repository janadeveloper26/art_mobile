import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:lottie/lottie.dart';

class DevicePendingApprovalPage extends StatelessWidget {
  const DevicePendingApprovalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animation
              SizedBox(
                height: 200,
                child: Lottie.network(
                  'https://assets9.lottiefiles.com/packages/lf20_ghp9v6cl.json', // Security/Clock animation
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    LucideIcons.shieldAlert,
                    size: 100,
                    color: Color(0xFF6A1B9A),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              
              Text(
                'Approval Pending',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF212121),
                ),
              ),
              const SizedBox(height: 16),
              
              Text(
                'Your device is currently awaiting administrator approval. This is a security measure to protect your account.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  color: const Color(0xFF757575),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F6FB),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF6A1B9A).withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.info, color: Color(0xFF6A1B9A), size: 20),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Approval usually takes less than 24 hours. You will receive a notification once approved.',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: const Color(0xFF6A1B9A),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
              
              // Check Status Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Re-login attempt or status check
                    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A1B9A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleWithBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Check Status',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              TextButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
                child: Text(
                  'Back to Login',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF757575),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RoundedRectangleWithBorder extends OutlinedBorder {
  final BorderRadiusGeometry borderRadius;
  const RoundedRectangleWithBorder({this.borderRadius = BorderRadius.zero});

  @override
  OutlinedBorder copyWith({BorderSide? side, BorderRadiusGeometry? borderRadius}) {
    return RoundedRectangleWithBorder(borderRadius: borderRadius ?? this.borderRadius);
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRRect(borderRadius.resolve(textDirection).toRRect(rect).deflate(side.width));
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRRect(borderRadius.resolve(textDirection).toRRect(rect));
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (rect.isEmpty) return;
    final paint = side.toPaint();
    final rrect = borderRadius.resolve(textDirection).toRRect(rect);
    canvas.drawRRect(rrect, paint);
  }

  @override
  ShapeBorder scale(double t) {
    return RoundedRectangleWithBorder(borderRadius: borderRadius * t);
  }
}
