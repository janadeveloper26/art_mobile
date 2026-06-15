import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:art_mobile/core/network/api_client.dart';
import 'package:art_mobile/features/courses/data/mock_course_service.dart';
import 'package:art_mobile/features/courses/data/models/course_model.dart';
import 'package:art_mobile/features/courses/data/models/explore_model.dart';
import 'package:art_mobile/features/my_courses/data/models/my_courses_model.dart';

class CourseRepositoryImpl implements ICourseRepository {
  final ApiClient apiClient;
  // Fallback mock — used when the real API endpoint doesn't exist yet
  // or returns an error (404, 500, network failure).
  // Remove once all backend endpoints are live and tested.
  final MockCourseRepository _mock = MockCourseRepository();

  CourseRepositoryImpl({required this.apiClient});

  @override
  Future<CourseDetail> getCourseDetail(String courseId) async {
    try {
      final response = await apiClient.get('courses/$courseId');
      if (response.data != null && response.data['data'] != null) {
        return CourseDetail.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      // API returned success but no 'data' field — fall back to mock
      debugPrint('⚠️ courses/$courseId: empty data, using mock fallback');
      return _mock.getCourseDetail(courseId);
    } catch (e) {
      // API not implemented yet or network error — use mock so UI is never broken
      debugPrint('⚠️ courses/$courseId failed ($e), using mock fallback');
      return _mock.getCourseDetail(courseId);
    }
  }

  @override
  Future<HomeResponse> getHomeData() async {
    try {
      final response = await apiClient.get('courses/home');
      if (response.data != null && response.data['data'] != null) {
        return HomeResponse.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      // API returned success but no 'data' field — fall back to mock
      debugPrint('⚠️ courses/home: empty data field, using mock fallback');
      return _mock.getHomeData();
    } catch (e) {
      // API not implemented yet or network error — use mock so UI is never empty
      debugPrint('⚠️ courses/home failed ($e), using mock fallback');
      return _mock.getHomeData();
    }
  }

  @override
  Future<ExploreResponse> getExploreData({String? query, String? category, String? filter}) async {
    try {
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

      debugPrint('⚠️ courses: unexpected format, using mock fallback');
      return _mock.getExploreData(query: query, category: category, filter: filter);
    } catch (e) {
      debugPrint('⚠️ courses failed ($e), using mock fallback');
      return _mock.getExploreData(query: query, category: category, filter: filter);
    }
  }

  @override
  Future<MyCoursesResponse> getMyCourses() async {
    try {
      final response = await apiClient.get('courses/my-courses');
      if (response.data != null && response.data['data'] != null) {
        return MyCoursesResponse.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      debugPrint('⚠️ courses/my-courses: empty data, using mock fallback');
      return _mock.getMyCourses();
    } catch (e) {
      debugPrint('⚠️ courses/my-courses failed ($e), using mock fallback');
      return _mock.getMyCourses();
    }
  }
}
