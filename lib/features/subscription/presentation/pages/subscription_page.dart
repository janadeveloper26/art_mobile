import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:art_mobile/core/config/service_locator.dart';
import 'package:art_mobile/core/theme/theme_colors.dart';
import 'package:art_mobile/core/theme/theme_manager.dart';
import '../../data/models/subscription_model.dart';
import '../../data/mock_subscription_repository.dart';
import '../bloc/subscription_bloc.dart';

class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SubscriptionBloc(sl<ISubscriptionRepository>())..add(LoadSubscriptionData()),
      child: const SubscriptionView(),
    );
  }
}

class SubscriptionView extends StatefulWidget {
  const SubscriptionView({super.key});

  @override
  State<SubscriptionView> createState() => _SubscriptionViewState();
}

class _SubscriptionViewState extends State<SubscriptionView> with TickerProviderStateMixin {
  late AnimationController _headerController;
  late Animation<double> _headerScale;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _headerScale = Tween<double>(begin: 1.1, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
    );
    _headerController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = sl<ThemeManager>().isDarkMode;
    return Scaffold(
      backgroundColor: isDark ? ThemeColors.backgroundDark : Colors.white,
      body: BlocBuilder<SubscriptionBloc, SubscriptionState>(
        builder: (context, state) {
          if (state is SubscriptionLoading) {
            return Center(child: CircularProgressIndicator(color: isDark ? ThemeColors.burgundyLight : const Color(0xFF6A1B9A)));
          }

          if (state is SubscriptionLoaded) {
            return _buildContent(context, state, isDark);
          }

          if (state is SubscriptionError) {
            return Center(child: Text(state.message));
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, SubscriptionLoaded state, bool isDark) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildHeader(state, isDark),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                ...state.data.plans.map((plan) => _buildPlanCard(context, plan, state.selectedPlanId == plan.id, isDark)),
                const SizedBox(height: 32),
                _buildCTA(state.selectedPlan),
                const SizedBox(height: 16),
                Text(
                  'Cancel anytime · Secure payment · 7-day refund guarantee',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 32),
                _buildTestimonial(state.data.testimonial, isDark),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(SubscriptionLoaded state, bool isDark) {
    return ScaleTransition(
      scale: _headerScale,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6A1B9A), Color(0xFFAB47BC)],
          ),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 60, 24, 48),
        child: Stack(
          children: [
            Positioned(top: -40, right: -40, child: CircleAvatar(radius: 80, backgroundColor: Colors.white.withOpacity(0.06))),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                    child: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(height: 32),
                Text(state.data.headerTitle, style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white, height: 1.1)),
                const SizedBox(height: 12),
                Text(state.data.headerSubtitle, style: GoogleFonts.outfit(fontSize: 15, color: Colors.white.withOpacity(0.9), height: 1.5)),
                const SizedBox(height: 24),
                Wrap(spacing: 8, runSpacing: 8, children: state.data.highlights.map((h) => _buildHighlightPill(h)).toList()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightPill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.1))),
      child: Text(label, style: GoogleFonts.outfit(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildPlanCard(BuildContext context, SubscriptionPlan plan, bool isSelected, bool isDark) {
    return GestureDetector(
      onTap: () => context.read<SubscriptionBloc>().add(SelectPlan(plan.id)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? null : (isDark ? ThemeColors.surfaceDark : Colors.white),
          gradient: isSelected ? LinearGradient(colors: plan.gradientColors) : null,
          borderRadius: BorderRadius.circular(28),
          border: isSelected ? null : Border.all(color: isDark ? ThemeColors.borderDark : const Color(0xFF6A1B9A).withOpacity(0.15), width: 1.5),
          boxShadow: [
            if (isSelected) BoxShadow(color: plan.gradientColors.first.withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 8))
            else BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(color: isSelected ? Colors.white.withOpacity(0.2) : plan.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                  child: Icon(plan.icon, color: isSelected ? Colors.white : plan.primaryColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(plan.label, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : (isDark ? Colors.white : const Color(0xFF1A1A1A)))),
                          if (plan.popular)
                            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFFFC107), borderRadius: BorderRadius.circular(10)), child: Text('POPULAR', style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black))),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text('₹${plan.price}', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w900, color: isSelected ? Colors.white : (isDark ? const Color(0xFFE1BEE7) : plan.primaryColor))),
                          const SizedBox(width: 6),
                          Text(plan.period, style: GoogleFonts.outfit(fontSize: 12, color: isSelected ? Colors.white.withOpacity(0.8) : Colors.grey.shade500)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Divider(color: isSelected ? Colors.white24 : (isDark ? Colors.white10 : Colors.grey.shade100)),
            const SizedBox(height: 12),
            ...plan.features.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(LucideIcons.checkCircle2, color: isSelected ? Colors.white : plan.primaryColor, size: 14),
                  const SizedBox(width: 12),
                  Text(f, style: GoogleFonts.outfit(fontSize: 13, color: isSelected ? Colors.white.withOpacity(0.9) : (isDark ? Colors.grey.shade400 : Colors.grey.shade600))),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildCTA(SubscriptionPlan plan) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: plan.gradientColors),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: plan.gradientColors.first.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(20),
          child: Center(child: Text('UNLOCK ALL ACCESS · ₹${plan.price}', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1))),
        ),
      ),
    );
  }

  Widget _buildTestimonial(TestimonialModel testimonial, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: isDark ? ThemeColors.surfaceDark : const Color(0xFFF8F6FB), borderRadius: BorderRadius.circular(28), border: Border.all(color: isDark ? ThemeColors.borderDark : Colors.transparent)),
      child: Column(
        children: [
          const Icon(LucideIcons.quote, color: Color(0xFF6A1B9A), size: 24),
          const SizedBox(height: 16),
          Text(testimonial.quote, style: GoogleFonts.outfit(fontSize: 15, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontStyle: FontStyle.italic, height: 1.6), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(radius: 20, backgroundColor: const Color(0xFF6A1B9A), child: Text(testimonial.initial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(testimonial.author, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
                Text(testimonial.role, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade500)),
              ]),
            ],
          ),
        ],
      ),
    );
  }
}
