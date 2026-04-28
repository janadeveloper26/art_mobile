class CourseDetail {
  final String id;
  final String title;
  final String description;
  final String instructor;
  final String instructorAvatar;
  final String instructorRole;
  final String level;
  final String category;
  final String duration;
  final int lessonCount;
  final double rating;
  final int reviews;
  final int students;
  final int price;
  final int originalPrice;
  final String image;
  final bool isWishlisted;
  final List<CurriculumSection> curriculum;
  final List<CourseReview> reviewsList;

  CourseDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.instructor,
    required this.instructorAvatar,
    required this.instructorRole,
    required this.level,
    required this.category,
    required this.duration,
    required this.lessonCount,
    required this.rating,
    required this.reviews,
    required this.students,
    required this.price,
    required this.originalPrice,
    required this.image,
    this.isWishlisted = false,
    required this.curriculum,
    required this.reviewsList,
  });
}

class CurriculumSection {
  final String id;
  final String title;
  final List<CourseLesson> lessons;

  CurriculumSection({
    required this.id,
    required this.title,
    required this.lessons,
  });
}

class CourseLesson {
  final String id;
  final String title;
  final String duration;
  final String videoUrl;
  final bool isCompleted;
  final bool isPreview;

  CourseLesson({
    required this.id,
    required this.title,
    required this.duration,
    required this.videoUrl,
    this.isCompleted = false,
    this.isPreview = false,
  });
}

class CourseReview {
  final String id;
  final String name;
  final String avatar;
  final double rating;
  final String comment;
  final String date;

  CourseReview({
    required this.id,
    required this.name,
    required this.avatar,
    required this.rating,
    required this.comment,
    required this.date,
  });
}

class HomeResponse {
  final List<BannerModel> banners;
  final List<CourseSummary> continueLearning;
  final List<CourseSummary> featuredCourses;
  final List<String> categories;
  final List<InstructorSummary> instructors;

  HomeResponse({
    required this.banners,
    required this.continueLearning,
    required this.featuredCourses,
    required this.categories,
    required this.instructors,
  });

  factory HomeResponse.fromJson(Map<String, dynamic> json) {
    return HomeResponse(
      categories: (json['categories'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      banners: (json['banners'] as List<dynamic>?)
              ?.map((e) => BannerModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      continueLearning: (json['continue_learning'] as List<dynamic>?)
              ?.map((e) => CourseSummary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      featuredCourses: (json['featured_courses'] as List<dynamic>?)
              ?.map((e) => CourseSummary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      instructors: (json['instructors'] as List<dynamic>?)
              ?.map((e) => InstructorSummary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class BannerModel {
  final String title;
  final String subtitle;
  final String badge;
  final String image;
  final List<int> colors; // List of ARGB values for gradient

  BannerModel({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.image,
    required this.colors,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      badge: json['badge'] as String? ?? '',
      image: json['image'] as String? ?? '',
      colors: (json['colors'] as List<dynamic>?)?.map((e) => e as int).toList() ?? [],
    );
  }
}

class CourseSummary {
  final String id;
  final String title;
  final String instructor;
  final String category;
  final String image;
  final double? progress;
  final String? badge;
  final String? discount;
  final double rating;
  final int reviews;
  final int price;
  final int originalPrice;
  final String level;

  CourseSummary({
    required this.id,
    required this.title,
    required this.instructor,
    required this.category,
    required this.image,
    this.progress,
    this.badge,
    this.discount,
    this.rating = 0.0,
    this.reviews = 0,
    this.price = 0,
    this.originalPrice = 0,
    this.level = 'Beginner',
  });

  factory CourseSummary.fromJson(Map<String, dynamic> json) {
    return CourseSummary(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      instructor: json['instructor'] as String? ?? 'Unknown',
      category: json['category'] as String? ?? 'Uncategorized',
      image: json['image'] as String? ?? '',
      progress: json['progress'] != null ? (json['progress'] as num).toDouble() : null,
      badge: json['badge'] as String?,
      discount: json['discount'] as String?,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : 0.0,
      reviews: (json['reviews'] as num?)?.toInt() ?? 0,
      price: (json['price'] as num?)?.toInt() ?? 0,
      originalPrice: (json['original_price'] as num?)?.toInt() ?? 0,
      level: json['level'] as String? ?? 'Beginner',
    );
  }
}

class InstructorSummary {
  final String name;
  final String initial;
  final List<int> colors;

  InstructorSummary({
    required this.name,
    required this.initial,
    required this.colors,
  });

  factory InstructorSummary.fromJson(Map<String, dynamic> json) {
    return InstructorSummary(
      name: json['name'] as String? ?? '',
      initial: json['initial'] as String? ?? '',
      colors: (json['colors'] as List<dynamic>?)?.map((e) => e as int).toList() ?? [],
    );
  }
}
