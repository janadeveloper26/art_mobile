import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class VideoProgressService {
  final SharedPreferences _prefs;

  VideoProgressService(this._prefs);

  // --- Position Tracking ---

  String _positionKey(String lessonId) => 'video_pos_$lessonId';

  Future<void> savePosition(String lessonId, Duration position) async {
    // Only save if progress is meaningful (e.g. past 2 seconds)
    if (position.inSeconds > 2) {
      await _prefs.setInt(_positionKey(lessonId), position.inMilliseconds);
    }
  }

  Duration? getPosition(String lessonId) {
    final ms = _prefs.getInt(_positionKey(lessonId));
    if (ms != null && ms > 0) {
      return Duration(milliseconds: ms);
    }
    return null;
  }

  Future<void> clearPosition(String lessonId) async {
    await _prefs.remove(_positionKey(lessonId));
  }

  // --- Completion Tracking ---

  String _completionKey(String courseId) => 'course_comp_$courseId';

  Future<void> markLessonComplete(String courseId, String lessonId) async {
    final completed = getCompletedLessons(courseId);
    if (!completed.contains(lessonId)) {
      completed.add(lessonId);
      await _prefs.setString(_completionKey(courseId), jsonEncode(completed.toList()));
    }
    // Also clear the saved position since it's completed
    await clearPosition(lessonId);
  }

  Set<String> getCompletedLessons(String courseId) {
    final str = _prefs.getString(_completionKey(courseId));
    if (str != null) {
      try {
        final List<dynamic> list = jsonDecode(str);
        return list.map((e) => e.toString()).toSet();
      } catch (_) {}
    }
    return {};
  }

  double getCompletionPercent(String courseId, int totalLessons) {
    if (totalLessons == 0) return 0.0;
    final completed = getCompletedLessons(courseId).length;
    return (completed / totalLessons).clamp(0.0, 1.0);
  }
}
