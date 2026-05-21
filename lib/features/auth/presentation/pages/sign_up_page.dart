import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:art_mobile/core/routing/app_routes.dart';
import '../bloc/login_bloc.dart';

/// [SignUpPage] translated from the provided React component.
/// It uses the existing LoginBloc for state management since Phone/Google auth 
/// share the same core logic as Sign In.
class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(),
      child: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          if (state.isOtpSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('OTP sent to +91 ${state.phoneNumber}'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.pushNamed(
              context, 
              AppRoutes.verifyOtp,
              arguments: {
                'phoneNumber': '+91 ${state.phoneNumber}',
                'verificationId': state.verificationId,
                'mode': 'signup',
              },
            );
          } else if (state.isPendingApproval) {
            Navigator.pushNamed(context, AppRoutes.devicePendingApproval);
          } else if (state.isGoogleSuccess) {
            Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
          }
        },
        child: const SignUpView(),
      ),
    );
  }
}

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ---------------------------------------------------------
            // 1. GRADIENT HEADER WITH WAVE
            // ---------------------------------------------------------
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 50),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF6A1B9A), Color(0xFFAB47BC)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                          child: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 18),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text('Create Account', style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
                      const SizedBox(height: 6),
                      Text('Join 10,000+ learners on AariLearn', style: GoogleFonts.outfit(fontSize: 13, color: Colors.white.withOpacity(0.75))),
                    ],
                  ),
                ),
                // Decorative Circle
                Positioned(
                  top: -60, 
                  right: -40, 
                  child: Container(
                    width: 180, 
                    height: 180, 
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.07), shape: BoxShape.circle)
                  )
                ),
                // Wave Bottom
                Positioned(
                  bottom: -1,
                  left: 0,
                  right: 0,
                  child: RepaintBoundary(
                    child: SizedBox(
                      height: 40,
                      width: double.infinity,
                      child: CustomPaint(painter: SignUpWavePainter(color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),

            // ---------------------------------------------------------
            // 2. FORM & BUTTONS
            // ---------------------------------------------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: BlocBuilder<LoginBloc, LoginState>(
                builder: (context, state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // Google Button
                      _buildGoogleButton(context, state),

                      const SizedBox(height: 20),

                      // Divider
                      Row(
                        children: [
                          const Expanded(child: Divider(color: Colors.black12)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text('or use phone number', style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF9E9E9E))),
                          ),
                          const Expanded(child: Divider(color: Colors.black12)),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Phone Input
                      Text('Phone Number', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF212121))),
                      const SizedBox(height: 8),
                      _buildPhoneInput(context, state),

                      const SizedBox(height: 24),

                      // Send OTP
                      _buildSendOtpButton(context, state),

                      const SizedBox(height: 24),

                      // Benefits Section
                      _buildBenefits(),

                      const SizedBox(height: 20),

                      // Sign In Link
                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFF757575)),
                              children: const [
                                TextSpan(text: 'Already have an account? '),
                                TextSpan(text: 'Sign In', style: TextStyle(color: Color(0xFF6A1B9A), fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleButton(BuildContext context, LoginState state) {
    return GestureDetector(
      onTap: state.isLoading ? null : () => context.read<LoginBloc>().add(GoogleSignInPressed()),
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withOpacity(0.12)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 2))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildGoogleIcon(),
            const SizedBox(width: 12),
            Text('Continue with Google', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF212121))),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneInput(BuildContext context, LoginState state) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F6FB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF6A1B9A).withOpacity(0.15), width: 1.5),
      ),
      child: Row(
        children: [
          Row(
            children: [
              const Text('🇮🇳', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text('+91', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF212121))),
              const SizedBox(width: 12),
              Container(width: 1, height: 20, color: Colors.black.withOpacity(0.1)),
              const SizedBox(width: 12),
            ],
          ),
          const Icon(LucideIcons.phone, size: 16, color: Color(0xFF9E9E9E)),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              onChanged: (val) => context.read<LoginBloc>().add(PhoneNumberChanged(val)),
              style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w500, color: const Color(0xFF212121), letterSpacing: 0.5),
              decoration: const InputDecoration(
                hintText: 'Enter mobile number', 
                hintStyle: TextStyle(color: Color(0xFF9E9E9E)), 
                border: InputBorder.none,
                counterText: '',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSendOtpButton(BuildContext context, LoginState state) {
    final isReady = state.phoneNumber.length >= 10;
    return GestureDetector(
      onTap: (state.isLoading || !isReady) ? null : () => context.read<LoginBloc>().add(SendOtpPressed()),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          gradient: isReady ? const LinearGradient(colors: [Color(0xFF6A1B9A), Color(0xFFAB47BC)], begin: Alignment.topLeft, end: Alignment.bottomRight) : null,
          color: isReady ? null : const Color(0xFF6A1B9A).withOpacity(0.2),
          borderRadius: BorderRadius.circular(14),
          boxShadow: isReady ? [BoxShadow(color: const Color(0xFF6A1B9A).withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 8))] : null,
        ),
        alignment: Alignment.center,
        child: state.isLoading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Send OTP', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(width: 10),
                  const Icon(LucideIcons.chevronRight, color: Colors.white, size: 18),
                ],
              ),
      ),
    );
  }

  Widget _buildBenefits() {
    final benefits = [
      "Access to 10 free courses",
      "Community forums & discussion",
      "Progress tracking & certificates",
      "Mobile app with offline access",
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F6FB),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('✨ What you get for FREE', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF6A1B9A))),
          const SizedBox(height: 12),
          ...benefits.map((b) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Icon(Icons.check, color: Color(0xFF4CAF50), size: 14),
                const SizedBox(width: 8),
                Text(b, style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF757575))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildGoogleIcon() {
    return RepaintBoundary(
      child: SizedBox(
        width: 20,
        height: 20,
        child: CustomPaint(
          painter: SignUpGoogleIconPainter(),
        ),
      ),
    );
  }
}

class SignUpWavePainter extends CustomPainter {
  final Color color;
  SignUpWavePainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    path.moveTo(0, size.height * 0.625);
    path.quadraticBezierTo(size.width * 0.5, size.height * 0.125, size.width, size.height * 0.625);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class SignUpGoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -0.5, 1.0, true, paint);
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), 0.5, 2.0, true, paint);
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), 2.5, 1.0, true, paint);
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), 3.5, 2.5, true, paint);
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
