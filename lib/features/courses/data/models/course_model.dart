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
}
