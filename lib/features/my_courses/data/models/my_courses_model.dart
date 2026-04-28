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
}
