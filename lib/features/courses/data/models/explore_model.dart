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

  factory ExploreResponse.fromJson(Map<String, dynamic> json) {
    final coursesJson = _listFromAny(
      json['courses'] ??
          json['results'] ??
          json['items'] ??
          json['data'] ??
          json['course_list'],
    );
    final courses = coursesJson
        .map(_mapFromAny)
        .whereType<Map<String, dynamic>>()
        .map(CourseSummary.fromJson)
        .toList();
    final categories = (json['categories'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        _categoriesFromCourses(courses);

    return ExploreResponse(
      courses: courses,
      categories: categories,
      filters: (json['filters'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  factory ExploreResponse.fromList(List<dynamic> json) {
    final courses = json
        .map(_mapFromAny)
        .whereType<Map<String, dynamic>>()
        .map(CourseSummary.fromJson)
        .toList();

    return ExploreResponse(
      courses: courses,
      categories: _categoriesFromCourses(courses),
      filters: const [],
    );
  }
}

List<dynamic> _listFromAny(dynamic value) {
  if (value is List<dynamic>) return value;
  if (value is Map<String, dynamic>) {
    return _listFromAny(
      value['courses'] ??
          value['results'] ??
          value['items'] ??
          value['data'] ??
          value['course_list'],
    );
  }
  return const [];
}

Map<String, dynamic>? _mapFromAny(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

List<String> _categoriesFromCourses(List<CourseSummary> courses) {
  final categories = courses
      .map((course) => course.category)
      .where((category) => category.isNotEmpty)
      .toSet()
      .toList()
    ..sort();

  return ['All', ...categories.where((category) => category != 'All')];
}
