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
  final String videoUrl;
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
    this.videoUrl = '',
    this.isWishlisted = false,
    required this.curriculum,
    required this.reviewsList,
  });

  factory CourseDetail.fromJson(Map<String, dynamic> json) {
    final curriculumJson = _listFromAny(json['curriculum'] ?? json['sections'] ?? json['modules'] ?? json['lessons']);
    final reviewsJson = _listFromAny(json['reviews_list'] ?? json['reviews'] ?? json['testimonials']);
    return CourseDetail(
      id: _stringFromAny(json['id']),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      instructor: _stringFromAny(json['instructor_name'] ?? json['instructor']),
      instructorAvatar: json['instructor_avatar'] as String? ?? '',
      instructorRole: json['instructor_role'] as String? ?? '',
      level: json['level'] as String? ?? '',
      category: json['category'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      lessonCount: (json['lesson_count'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviews: (json['reviews'] as num?)?.toInt() ?? 0,
      students: (json['students'] as num?)?.toInt() ?? 0,
      price: (json['price'] as num?)?.toInt() ?? 0,
      originalPrice: (json['original_price'] as num?)?.toInt() ?? 0,
      image: json['image'] as String? ?? '',
      videoUrl: _stringFromAny(
        json['video_url'] ??
            json['video'] ??
            json['s3_video_url'] ??
            json['video_file'] ??
            json['preview_video_url'] ??
            json['trailer_url'] ??
            json['promo_video_url'],
      ),
      isWishlisted: json['is_wishlisted'] as bool? ?? false,
      curriculum: curriculumJson.map(_mapFromAny).whereType<Map<String, dynamic>>().map(CurriculumSection.fromJson).toList(),
      reviewsList: reviewsJson.map(_mapFromAny).whereType<Map<String, dynamic>>().map(CourseReview.fromJson).toList(),
    );
  }
}

String _stringFromAny(dynamic value) {
  if (value == null) return '';
  if (value is String) return value;
  if (value is Map<String, dynamic>) {
    return _stringFromAny(
      value['url'] ??
          value['video_url'] ??
          value['s3_url'] ??
          value['file'] ??
          value['key'] ??
          value['name'] ??
          value['full_name'] ??
          value['title'],
    );
  }
  return value.toString();
}

List<dynamic> _listFromAny(dynamic value) {
  if (value is List<dynamic>) return value;
  if (value is Map<String, dynamic>) {
    return _listFromAny(
      value['curriculum'] ??
          value['sections'] ??
          value['modules'] ??
          value['lessons'] ??
          value['reviews_list'] ??
          value['reviews'],
    );
  }
  return const [];
}

Map<String, dynamic>? _mapFromAny(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
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

  factory CurriculumSection.fromJson(Map<String, dynamic> json) {
    return CurriculumSection(
      id: _stringFromAny(json['id']),
      title: json['title'] as String? ?? '',
      lessons: (json['lessons'] as List<dynamic>?)
              ?.map((e) => CourseLesson.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
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

  factory CourseLesson.fromJson(Map<String, dynamic> json) {
    return CourseLesson(
      id: _stringFromAny(json['id']),
      title: json['title'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      videoUrl: _stringFromAny(json['video_url'] ?? json['video'] ?? json['s3_video_url'] ?? json['video_file']),
      isCompleted: json['is_completed'] as bool? ?? false,
      isPreview: json['is_preview'] as bool? ?? false,
    );
  }
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

  factory CourseReview.fromJson(Map<String, dynamic> json) {
    return CourseReview(
      id: _stringFromAny(json['id']),
      name: json['name'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      comment: json['comment'] as String? ?? '',
      date: json['date'] as String? ?? '',
    );
  }
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
      id: _stringFromAny(json['id']),
      title: json['title'] as String? ?? '',
      instructor: _stringFromAny(json['instructor_name'] ?? json['instructor']).isNotEmpty ? _stringFromAny(json['instructor_name'] ?? json['instructor']) : 'Unknown',
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
