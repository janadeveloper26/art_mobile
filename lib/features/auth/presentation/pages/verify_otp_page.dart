import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:art_mobile/core/routing/app_routes.dart';
import 'package:art_mobile/core/theme/theme_colors.dart';
import '../bloc/otp_bloc.dart';

/// [VerifyOtpPage] provides a premium, high-fidelity verification experience.
/// Translates the React motion design into a native Flutter flow with
/// glassmorphism hints and sophisticated animations.
class VerifyOtpPage extends StatelessWidget {
  final String phoneNumber;
  final String verificationId;

  const VerifyOtpPage({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OtpBloc(
        phoneNumber: phoneNumber,
        verificationId: verificationId,
      )..add(StartResendTimer()),
      child: BlocListener<OtpBloc, OtpState>(
        listener: (context, state) async {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          if (state.isVerified) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('OTP Verified Successfully!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            // Success animation delay
            await Future.delayed(const Duration(milliseconds: 1000));
            if (context.mounted) {
              Navigator.pushNamedAndRemoveUntil(
                  context, AppRoutes.home, (route) => false);
            }
          } else if (state.isPendingApproval) {
            Navigator.pushNamed(context, AppRoutes.devicePendingApproval);
          }
        },
        child: VerifyOtpView(phoneNumber: phoneNumber),
      ),
    );
  }
}

class VerifyOtpView extends StatefulWidget {
  final String phoneNumber;
  const VerifyOtpView({super.key, required this.phoneNumber});

  @override
  State<VerifyOtpView> createState() => _VerifyOtpViewState();
}

class _VerifyOtpViewState extends State<VerifyOtpView>
    with TickerProviderStateMixin {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  late AnimationController _entranceController;
  late AnimationController _shieldController;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _shieldController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));

    _entranceController.forward();
    _shieldController.forward();
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    _entranceController.dispose();
    _shieldController.dispose();
    super.dispose();
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  void _onOtpChange(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    setState(() {}); // Update button state
  }

  @override
  Widget build(BuildContext context) {
    final maskedPhone = widget.phoneNumber.length >= 10
        ? '${widget.phoneNumber.substring(0, 3)} ${widget.phoneNumber.substring(3, 5)}****${widget.phoneNumber.substring(widget.phoneNumber.length - 4)}'
        : widget.phoneNumber;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ---------------------------------------------------------
            // 1. GRADIENT HEADER
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
                      // Back Button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle),
                          child: const Icon(LucideIcons.arrowLeft,
                              color: Colors.white, size: 18),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text('Verify OTP',
                          style: GoogleFonts.outfit(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                      const SizedBox(height: 6),
                      Text(
                        'We\'ve sent a 6-digit code to\n$maskedPhone',
                        style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.75),
                            height: 1.5),
                      ),
                    ],
                  ),
                ),
                // Decorative Circle
                Positioned(
                  top: -50,
                  right: -30,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.07),
                        shape: BoxShape.circle),
                  ),
                ),
                // Header Wave
                Positioned(
                  bottom: -1,
                  left: 0,
                  right: 0,
                  child: RepaintBoundary(
                    child: SizedBox(
                      height: 40,
                      width: double.infinity,
                      child: CustomPaint(
                          painter: HeaderWavePainter(color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),

            // ---------------------------------------------------------
            // 2. FORM CONTENT
            // ---------------------------------------------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: BlocBuilder<OtpBloc, OtpState>(
                builder: (context, state) {
                  return Column(
                    children: [
                      const SizedBox(height: 16),
                      // Shield Icon / Success Icon
                      _buildSecurityIcon(state.isVerified),

                      const SizedBox(height: 24),

                      // OTP Input Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                            6,
                            (index) => _buildOtpBox(
                                index, state.errorMessage != null)),
                      ),

                      const SizedBox(height: 12),

                      // Error Message
                      if (state.errorMessage != null)
                        FadeTransition(
                          opacity: _entranceController,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(state.errorMessage!,
                                style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    color: const Color(0xFFEF5350))),
                          ),
                        ),

                      // Progress Bar (Dots)
                      _buildProgressDots(),

                      const SizedBox(height: 28),

                      // Verify Button
                      _buildVerifyButton(context, state),

                      const SizedBox(height: 20),

                      // Resend Logic
                      _buildResendSection(context, state),

                      const SizedBox(height: 32),

                      // Info Box
                      _buildInfoBox(),

                      const SizedBox(height: 16),

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

  Widget _buildSecurityIcon(bool isVerified) {
    return RepaintBoundary(
      child: ScaleTransition(
        scale: CurvedAnimation(
            parent: _shieldController, curve: Curves.elasticOut),
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFF6A1B9A).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: isVerified
                ? const Text('✅',
                    key: ValueKey('verified'), style: TextStyle(fontSize: 36))
                : const Icon(LucideIcons.shieldCheck,
                    key: ValueKey('shield'),
                    color: Color(0xFF6A1B9A),
                    size: 34),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpBox(int index, bool hasError) {
    final isFilled = _controllers[index].text.isNotEmpty;
    return Container(
      width: 48,
      height: 56,
      decoration: BoxDecoration(
        color: isFilled
            ? const Color(0xFF6A1B9A).withOpacity(0.08)
            : const Color(0xFFF8F6FB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isFilled
              ? const Color(0xFF6A1B9A).withOpacity(0.4)
              : (hasError
                  ? const Color(0xFFEF5350).withOpacity(0.4)
                  : const Color(0xFF6A1B9A).withOpacity(0.12)),
          width: 2,
        ),
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        onChanged: (val) => _onOtpChange(val, index),
        style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF6A1B9A)),
        decoration:
            const InputDecoration(counterText: '', border: InputBorder.none),
      ),
    );
  }

  Widget _buildProgressDots() {
    final filledCount = _controllers.where((c) => c.text.isNotEmpty).length;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (i) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 28,
          height: 3,
          decoration: BoxDecoration(
            color: i < filledCount
                ? const Color(0xFF6A1B9A)
                : const Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }

  Widget _buildVerifyButton(BuildContext context, OtpState state) {
    final isReady = _otpCode.length == 6;
    return GestureDetector(
      onTap: (state.isLoading || state.isVerified || !isReady)
          ? null
          : () => context.read<OtpBloc>().add(VerifyOtpPressed(_otpCode)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          gradient: isReady
              ? const LinearGradient(
                  colors: [Color(0xFF6A1B9A), Color(0xFFAB47BC)])
              : null,
          color: isReady ? null : const Color(0xFF6A1B9A).withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
          boxShadow: isReady
              ? [
                  BoxShadow(
                      color: const Color(0xFF6A1B9A).withOpacity(0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 8))
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: state.isLoading
? const SizedBox(
                            width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : Text(
                state.isVerified ? '✓ Verified!' : 'Verify & Continue',
                style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isReady
                        ? Colors.white
                        : const Color(0xFF6A1B9A).withOpacity(0.4)),
              ),
      ),
    );
  }

  Widget _buildResendSection(BuildContext context, OtpState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Didn\'t receive the code? ',
            style: GoogleFonts.outfit(
                fontSize: 13, color: const Color(0xFF757575))),
        state.resendTimer > 0
            ? Text('Resend in ${state.resendTimer}s',
                style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: const Color(0xFF9E9E9E),
                    fontWeight: FontWeight.w600))
            : GestureDetector(
                onTap: () {
                  for (var c in _controllers) {
                    c.clear();
                  }
                  _focusNodes[0].requestFocus();
                  context.read<OtpBloc>().add(ResendOtpPressed());
                },
                child: Text('Resend OTP',
                    style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: const Color(0xFF6A1B9A),
                        fontWeight: FontWeight.bold)),
              ),
      ],
    );
  }

  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: const Color(0xFFF8F6FB),
          borderRadius: BorderRadius.circular(14)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🔒', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your phone number is encrypted and never shared. OTP expires in 10 minutes.',
              style: GoogleFonts.outfit(
                  fontSize: 12, color: const Color(0xFF757575), height: 1.6),
            ),
          ),
        ],
      ),
    );
  }
}

class HeaderWavePainter extends CustomPainter {
  final Color color;
  HeaderWavePainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    // M0 25 Q195 5 390 25 L390 40 L0 40 Z
    path.moveTo(0, size.height * 0.625);
    path.quadraticBezierTo(
        size.width * 0.5, size.height * 0.125, size.width, size.height * 0.625);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
