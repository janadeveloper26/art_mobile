import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:lottie/lottie.dart';
import 'package:art_mobile/core/config/service_locator.dart';
import 'package:art_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:art_mobile/core/routing/app_routes.dart';

class DevicePendingApprovalPage extends StatefulWidget {
  const DevicePendingApprovalPage({super.key});

  @override
  State<DevicePendingApprovalPage> createState() => _DevicePendingApprovalPageState();
}

class _DevicePendingApprovalPageState extends State<DevicePendingApprovalPage> {
  bool _isLoading = false;

  Future<void> _checkStatus() async {
    setState(() => _isLoading = true);
    
    final repo = sl<IAuthRepository>();
    final result = await repo.checkApprovalStatus();
    
    if (!mounted) return;
    
    setState(() => _isLoading = false);
    
    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      (isApproved) {
        if (isApproved) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Device Approved!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Still pending administrator approval.'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );
  }

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
                  onPressed: _isLoading ? null : _checkStatus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A1B9A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleWithBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
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
                onPressed: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false),
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
    return Path()..addRRect(borderRadius.resolve(textDirection).toRRect(rect).deflate(side?.width ?? 0));
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRRect(borderRadius.resolve(textDirection).toRRect(rect));
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (rect.isEmpty) return;
    if (side != null && side!.style != BorderStyle.none) {
      final paint = side!.toPaint();
      final rrect = borderRadius.resolve(textDirection).toRRect(rect);
      canvas.drawRRect(rrect, paint);
    }
  }

  @override
  ShapeBorder scale(double t) {
    return RoundedRectangleWithBorder(borderRadius: borderRadius * t);
  }
}
