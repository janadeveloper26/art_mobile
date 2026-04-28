import 'package:art_mobile/features/courses/data/models/course_model.dart';

class ExploreResponse {
  final List<CourseSummary> courses;
  final List<String> categories;
  final List<String> filters;

  ExploreResponse({
    required this.courses,
    required this.categories,
    required this.filters,
  });
}
