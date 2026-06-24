import 'package:dio/dio.dart';
import 'package:art_mobile/core/network/api_client.dart';
import 'package:art_mobile/features/courses/domain/repositories/course_repository.dart';
import 'package:art_mobile/features/courses/data/models/course_model.dart';
import 'package:art_mobile/features/courses/data/models/explore_model.dart';
import 'package:art_mobile/features/my_courses/data/models/my_courses_model.dart';

class CourseRepositoryImpl implements ICourseRepository {
  final ApiClient apiClient;

  CourseRepositoryImpl({required this.apiClient});

  @override
  Future<CourseDetail> getCourseDetail(String courseId) async {
    final response = await apiClient.get('courses/$courseId');
    if (response.data != null && response.data['data'] != null) {
      return CourseDetail.fromJson(response.data['data'] as Map<String, dynamic>);
    }
    throw Exception('Invalid data format from API');
  }

  @override
  Future<HomeResponse> getHomeData() async {
    final response = await apiClient.get('courses/home');
    if (response.data != null && response.data['data'] != null) {
      return HomeResponse.fromJson(response.data['data'] as Map<String, dynamic>);
    }
    throw Exception('Invalid data format from API');
  }

  @override
  Future<ExploreResponse> getExploreData({String? query, String? category, String? filter}) async {
    final response = await apiClient.get(
      'courses',
      queryParameters: {
        if (query != null && query.trim().isNotEmpty) 'query': query.trim(),
        if (category != null && category != 'All') 'category': category,
        if (filter != null && filter != 'All') 'filter': filter,
      },
    );

    final responseData = response.data;
    if (responseData is List<dynamic>) {
      return ExploreResponse.fromList(responseData);
    }
    if (responseData is Map<String, dynamic>) {
      final data = responseData['data'];
      if (data is List<dynamic>) return ExploreResponse.fromList(data);
      if (data is Map<String, dynamic>) return ExploreResponse.fromJson(data);
      return ExploreResponse.fromJson(responseData);
    }

    throw Exception('Unexpected format from API');
  }

  @override
  Future<MyCoursesResponse> getMyCourses() async {
    final response = await apiClient.get('courses/my-courses');
    if (response.data != null && response.data['data'] != null) {
      return MyCoursesResponse.fromJson(response.data['data'] as Map<String, dynamic>);
    }
    throw Exception('Invalid data format from API');
  }
}
