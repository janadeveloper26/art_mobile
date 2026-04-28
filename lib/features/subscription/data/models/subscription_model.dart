import 'package:flutter/material.dart';

class SubscriptionPlan {
  final String id;
  final String label;
  final int price;
  final int originalPrice;
  final String period;
  final IconData icon;
  final Color primaryColor;
  final List<Color> gradientColors;
  final List<String> features;
  final bool popular;
  final String? savings;

  SubscriptionPlan({
    required this.id,
    required this.label,
    required this.price,
    required this.originalPrice,
    required this.period,
    required this.icon,
    required this.primaryColor,
    required this.gradientColors,
    required this.features,
    this.popular = false,
    this.savings,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    IconData getIconData(String? iconName) {
      switch (iconName) {
        case 'zap':
          return Icons.flash_on; // Use material flash_on or similar
        case 'crown':
          return Icons.workspace_premium;
        case 'infinity':
          return Icons.all_inclusive;
        default:
          return Icons.star;
      }
    }

    final colorsList = (json['colors'] as List<dynamic>?)?.map((e) => Color(e as int)).toList() ?? [Colors.purple, Colors.purpleAccent];
    final pColor = colorsList.isNotEmpty ? colorsList.first : Colors.purple;

    return SubscriptionPlan(
      id: json['id'] as String? ?? '',
      label: json['label'] as String? ?? '',
      price: (json['price'] as num?)?.toInt() ?? 0,
      originalPrice: (json['original_price'] as num?)?.toInt() ?? 0,
      period: json['period'] as String? ?? '',
      icon: getIconData(json['icon'] as String?),
      primaryColor: pColor,
      gradientColors: colorsList,
      features: (json['features'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      popular: json['popular'] as bool? ?? false,
      savings: json['savings'] as String?,
    );
  }
}

class SubscriptionResponse {
  final List<SubscriptionPlan> plans;
  final String headerTitle;
  final String headerSubtitle;
  final List<String> highlights;
  final TestimonialModel testimonial;

  SubscriptionResponse({
    required this.plans,
    required this.headerTitle,
    required this.headerSubtitle,
    required this.highlights,
    required this.testimonial,
  });

  factory SubscriptionResponse.fromJson(Map<String, dynamic> json) {
    return SubscriptionResponse(
      headerTitle: json['header_title'] as String? ?? '',
      headerSubtitle: json['header_subtitle'] as String? ?? '',
      highlights: (json['highlights'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      testimonial: TestimonialModel.fromJson(json['testimonial'] as Map<String, dynamic>? ?? {}),
      plans: (json['plans'] as List<dynamic>?)
              ?.map((e) => SubscriptionPlan.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class TestimonialModel {
  final String quote;
  final String author;
  final String role;
  final String initial;

  TestimonialModel({
    required this.quote,
    required this.author,
    required this.role,
    required this.initial,
  });

  factory TestimonialModel.fromJson(Map<String, dynamic> json) {
    return TestimonialModel(
      quote: json['quote'] as String? ?? '',
      author: json['author'] as String? ?? '',
      role: json['role'] as String? ?? '',
      initial: json['initial'] as String? ?? '',
    );
  }
}
