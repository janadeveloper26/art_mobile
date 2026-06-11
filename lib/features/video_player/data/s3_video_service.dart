import 'package:art_mobile/core/config/environment.dart';

/// Resolves a video URL stored in a [CourseLesson] into a playable [Uri].
///
/// Resolution order (no API calls made):
///   1. If [rawUrl] is already an absolute https URL → use as-is.
///   2. If [EnvironmentConfig.cloudFrontBaseUrl] is set → prepend it to the key.
///   3. Otherwise return an empty [Uri] so the player surfaces an error state.
class S3VideoService {
  const S3VideoService();

  /// Returns a [Uri] ready for [VideoPlayerController.networkUrl].
  /// Never throws — returns [Uri.empty] on invalid input.
  Uri resolveVideoUri(String? rawUrl) {
    if (rawUrl == null || rawUrl.trim().isEmpty) return Uri();

    final trimmed = rawUrl.trim();

    // Already a full URL (http or https)
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return Uri.tryParse(trimmed) ?? Uri();
    }

    // Relative S3 key — prepend CloudFront base URL if configured
    final base = EnvironmentConfig.cloudFrontBaseUrl.trim();
    if (base.isNotEmpty) {
      final separator = base.endsWith('/') ? '' : '/';
      final key = trimmed.startsWith('/') ? trimmed.substring(1) : trimmed;
      return Uri.tryParse('$base$separator$key') ?? Uri();
    }

    // Cannot resolve
    return Uri();
  }

  /// Returns true if [uri] is usable for playback.
  bool isValidUri(Uri uri) =>
      uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty;
}
