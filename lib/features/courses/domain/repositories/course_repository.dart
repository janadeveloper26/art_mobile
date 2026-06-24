import 'package:art_mobile/features/courses/data/models/course_model.dart';
import 'package:art_mobile/features/courses/data/models/explore_model.dart';
import 'package:art_mobile/features/my_courses/data/models/my_courses_model.dart';

abstract class ICourseRepository {
  Future<CourseDetail> getCourseDetail(String courseId);
  Future<HomeResponse> getHomeData();
  Future<ExploreResponse> getExploreData(
      {String? query, String? category, String? filter});
  Future<MyCoursesResponse> getMyCourses();
}
