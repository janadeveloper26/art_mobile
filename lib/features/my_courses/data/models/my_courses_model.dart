import '../../../courses/data/models/course_model.dart';

class MyCoursesResponse {
  final List<CourseSummary> ongoing;
  final List<CourseSummary> completed;
  final int totalEnrolled;
  final int totalCertificates;

  MyCoursesResponse({
    required this.ongoing,
    required this.completed,
    required this.totalEnrolled,
    required this.totalCertificates,
  });

  factory MyCoursesResponse.fromJson(Map<String, dynamic> json) {
    return MyCoursesResponse(
      ongoing: (json['ongoing'] as List<dynamic>?)
              ?.map((e) => CourseSummary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      completed: (json['completed'] as List<dynamic>?)
              ?.map((e) => CourseSummary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalEnrolled: (json['total_enrolled'] as num?)?.toInt() ?? 0,
      totalCertificates: (json['total_certificates'] as num?)?.toInt() ?? 0,
    );
  }
}
