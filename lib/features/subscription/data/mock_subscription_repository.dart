import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'models/subscription_model.dart';

abstract class ISubscriptionRepository {
  Future<SubscriptionResponse> getSubscriptionData();
}

class MockSubscriptionRepository implements ISubscriptionRepository {
  @override
  Future<SubscriptionResponse> getSubscriptionData() async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    return SubscriptionResponse(
      headerTitle: 'Unlock Premium',
      headerSubtitle: 'Get unlimited access to all Aari & Tailoring courses and learn from expert instructors',
      highlights: ['100+ Courses', 'Live Classes', 'Certificates', 'Offline Access'],
      testimonial: TestimonialModel(
        quote: '"Subscribing to the yearly plan was the best decision. I completed 8 courses and now run my own embroidery business!"',
        author: 'Sunitha Rao',
        role: 'Yearly subscriber',
        initial: 'S',
      ),
      plans: [
        SubscriptionPlan(
          id: 'monthly',
          label: 'Monthly',
          price: 299,
          originalPrice: 499,
          period: '/month',
          icon: LucideIcons.zap,
          primaryColor: const Color(0xFF4527A0),
          gradientColors: [const Color(0xFF4527A0), const Color(0xFF7E57C2)],
          features: [
            'Access to all courses',
            'HD video quality',
            'Download for offline',
            'Chat support',
          ],
        ),
        SubscriptionPlan(
          id: 'yearly',
          label: 'Yearly',
          price: 1999,
          originalPrice: 3588,
          period: '/year',
          icon: LucideIcons.crown,
          popular: true,
          savings: 'Save ₹1,589',
          primaryColor: const Color(0xFF6A1B9A),
          gradientColors: [const Color(0xFF6A1B9A), const Color(0xFFAB47BC)],
          features: [
            'Everything in Monthly',
            'Priority support',
            'Certificate of completion',
            'Exclusive live sessions',
            'Early access to new courses',
          ],
        ),
        SubscriptionPlan(
          id: 'lifetime',
          label: 'Lifetime',
          price: 4999,
          originalPrice: 12000,
          period: ' one-time',
          icon: LucideIcons.infinity,
          savings: 'Best Value',
          primaryColor: const Color(0xFF880E4F),
          gradientColors: [const Color(0xFF880E4F), const Color(0xFFAD1457)],
          features: [
            'Everything in Yearly',
            'Lifetime access',
            'All future courses',
            '1-on-1 mentorship sessions',
            'Physical kit delivery',
          ],
        ),
      ],
    );
  }
}
