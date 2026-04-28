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
}
