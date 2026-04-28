import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:art_mobile/core/routing/app_routes.dart';
import 'package:art_mobile/core/theme/theme_colors.dart';
import '../bloc/login_bloc.dart';

/// [LoginPage] provides a high-fidelity sign-in experience.
/// Translates the React design into a native Flutter layout with 
/// premium gradients, quick account selection, and smooth transitions.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

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
                'sessionId': state.sessionId,
              },
            );
          } else if (state.isGoogleSuccess) {
            Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
          }
        },
        child: const LoginView(),
      ),
    );
  }
}

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> with SingleTickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();
  late AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _entranceController.forward();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _entranceController.dispose();
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
            // 1. PREMIUM GRADIENT HEADER
            // ---------------------------------------------------------
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 50),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF4527A0), Color(0xFF6A1B9A), Color(0xFFAB47BC)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back Button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                          child: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 18),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(14)),
                            alignment: Alignment.center,
                            child: const Text('🪡', style: TextStyle(fontSize: 26)),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Welcome back!', style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
                              Text('Sign in to continue learning', style: GoogleFonts.outfit(fontSize: 13, color: Colors.white.withOpacity(0.75))),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Decorative Circle
                Positioned(top: -70, right: -50, child: Container(width: 200, height: 200, decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), shape: BoxShape.circle))),
                // Wave
                Positioned(
                  bottom: -1,
                  left: 0,
                  right: 0,
                  child: RepaintBoundary(
                    child: SizedBox(
                      height: 40,
                      width: double.infinity,
                      child: CustomPaint(painter: LoginWavePainter(color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),

            // ---------------------------------------------------------
            // 2. SIGN IN OPTIONS
            // ---------------------------------------------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: BlocBuilder<LoginBloc, LoginState>(
                builder: (context, state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      // Quick Sign In
                      Text('QUICK SIGN IN', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF9E9E9E), letterSpacing: 0.8)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildQuickAccount('👩', 'Priya Sharma', '9876543210', state.phoneNumber == '9876543210'),
                          const SizedBox(width: 12),
                          _buildQuickAccount('👩‍🦱', 'Meena Devi', '9123456789', state.phoneNumber == '9123456789'),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Google Sign In
                      _buildGoogleButton(context, state),

                      const SizedBox(height: 24),

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

                      const SizedBox(height: 24),

                      // Phone Number Input
                      Text('Phone Number', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF212121))),
                      const SizedBox(height: 10),
                      _buildPhoneInput(context, state),

                      const SizedBox(height: 24),

                      // Send OTP Button
                      _buildSendOtpButton(context, state),

                      const SizedBox(height: 24),

                      // Create Account Link
                      Center(
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFF757575)),
                            children: const [
                              TextSpan(text: 'New to AariLearn? '),
                              TextSpan(text: 'Create Account', style: TextStyle(color: Color(0xFF6A1B9A), fontWeight: FontWeight.bold)),
                            ],
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

  Widget _buildQuickAccount(String emoji, String name, String phone, bool isActive) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _phoneController.text = phone;
          context.read<LoginBloc>().add(PhoneNumberChanged(phone));
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF6A1B9A).withOpacity(0.08) : const Color(0xFFF8F6FB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isActive ? const Color(0xFF6A1B9A).withOpacity(0.3) : Colors.transparent, width: 1.5),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 4),
              Text(name, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: isActive ? const Color(0xFF6A1B9A) : const Color(0xFF212121))),
            ],
          ),
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
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.1)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF6A1B9A).withOpacity(0.15), width: 1.5),
      ),
      child: Row(
        children: [
          Row(
            children: [
              const Text('🇮🇳', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text('+91', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF212121))),
              const SizedBox(width: 12),
              Container(width: 1, height: 24, color: Colors.black12),
              const SizedBox(width: 12),
            ],
          ),
          const Icon(LucideIcons.phone, size: 16, color: Color(0xFF9E9E9E)),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              onChanged: (val) => context.read<LoginBloc>().add(PhoneNumberChanged(val)),
              style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w500, color: const Color(0xFF212121), letterSpacing: 0.5),
              decoration: const InputDecoration(hintText: 'Enter mobile number', hintStyle: TextStyle(color: Color(0xFF9E9E9E)), border: InputBorder.none),
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
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          gradient: isReady ? const LinearGradient(colors: [Color(0xFF6A1B9A), Color(0xFFAB47BC)]) : null,
          color: isReady ? null : const Color(0xFF6A1B9A).withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isReady ? [BoxShadow(color: const Color(0xFF6A1B9A).withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 8))] : null,
        ),
        alignment: Alignment.center,
        child: state.isLoading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Send OTP', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(width: 8),
                  const Icon(LucideIcons.chevronRight, color: Colors.white, size: 18),
                ],
              ),
      ),
    );
  }

  Widget _buildGoogleIcon() {
    return RepaintBoundary(
      child: SizedBox(
        width: 20,
        height: 20,
        child: CustomPaint(
          painter: GoogleIconPainter(),
        ),
      ),
    );
  }
}

class LoginWavePainter extends CustomPainter {
  final Color color;
  LoginWavePainter({required this.color});
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

class GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Basic Google color path representation (simplified)
    final paint = Paint();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // We'll use simple colored arcs to represent the G icon for this demo
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
