import 'package:dio/dio.dart';
import 'package:art_mobile/core/network/api_client.dart';
import 'package:art_mobile/features/courses/data/mock_course_service.dart';
import 'package:art_mobile/features/courses/data/models/course_model.dart';
import 'package:art_mobile/features/courses/data/models/explore_model.dart';
import 'package:art_mobile/features/my_courses/data/models/my_courses_model.dart';

class CourseRepositoryImpl implements ICourseRepository {
  final ApiClient apiClient;

  CourseRepositoryImpl({required this.apiClient});

  @override
  Future<CourseDetail> getCourseDetail(String courseId) async {
    try {
      final response = await apiClient.get('courses/$courseId');
      if (response.data != null && response.data['data'] != null) {
        return CourseDetail.fromJson(response.data['data'] as Map<String, dynamic>);
      } else {
        throw Exception('Invalid API response format for CourseDetail');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<HomeResponse> getHomeData() async {
    try {
      final response = await apiClient.get('courses/home');
      if (response.data != null && response.data['data'] != null) {
        return HomeResponse.fromJson(response.data['data'] as Map<String, dynamic>);
      } else {
        throw Exception('Invalid API response format');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ExploreResponse> getExploreData({String? query, String? category, String? filter}) async {
    try {
      final response = await apiClient.get(
        'courses/explore',
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
        if (data is List<dynamic>) {
          return ExploreResponse.fromList(data);
        }
        if (data is Map<String, dynamic>) {
          return ExploreResponse.fromJson(data);
        }
        return ExploreResponse.fromJson(responseData);
      }

      throw Exception('Invalid API response format for ExploreResponse');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<MyCoursesResponse> getMyCourses() async {
    try {
      final response = await apiClient.get('courses/my-courses');
      if (response.data != null && response.data['data'] != null) {
        return MyCoursesResponse.fromJson(response.data['data'] as Map<String, dynamic>);
      } else {
        throw Exception('Invalid API response format for MyCoursesResponse');
      }
    } catch (e) {
      rethrow;
    }
  }
}
