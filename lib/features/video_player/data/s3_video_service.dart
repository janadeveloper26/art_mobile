import 'dart:async';
import 'package:art_mobile/core/network/api_client.dart';
import 'package:flutter/foundation.dart';

class S3VideoService {
  final ApiClient _apiClient;
  final String _cloudFrontBaseUrl;

  // Cache: fileName -> signed URL
  final Map<String, String> _urlCache = {};

  // Deduplication: fileName -> in-flight future
  final Map<String, Future<String>> _inflightRequests = {};

  static const int _expirationBufferSeconds = 300;

  S3VideoService({
    required ApiClient apiClient,
    String cloudFrontBaseUrl = 'd3aj7czvezt6jf.cloudfront.net',
  })  : _apiClient = apiClient,
        _cloudFrontBaseUrl = cloudFrontBaseUrl;

  /// Resolves any video URL/file name to a playable CloudFront or signed URL.
  ///
  /// Priority:
  /// 1. Cached signed URL (if still within expiry buffer)
  /// 2. Fresh signed URL from [POST /videos/signed-url]
  /// 3. Full HTTPS URL as-is (with S3→CloudFront domain replacement if configured)
  Future<Uri> resolveVideoUri(String rawUrlOrFileName) async {
    if (rawUrlOrFileName.trim().isEmpty) return Uri();

    final key = rawUrlOrFileName.trim();
    final fileName = _extractFileName(key);

    // 1. Try signed URL from cache or API
    if (fileName.isNotEmpty) {
      try {
        debugPrint('S3VideoService: fetching signed URL for $fileName');
        final signedUrl = await _getOrFetchSignedUrl(fileName);
        debugPrint('S3VideoService: signed URL received: $signedUrl');
        final transformed = _replaceS3WithCloudFront(signedUrl);
        final uri = Uri.tryParse(transformed);
        if (uri != null && uri.host.isNotEmpty) {
          debugPrint('S3VideoService: using signed URL');
          return uri;
        }
      } catch (e) {
        debugPrint(
            'S3VideoService: signed URL failed ($e), falling back to original');
      }
    }

    // 2. Fallback: use original URL with S3→CloudFront transform
    if (key.startsWith('http://') || key.startsWith('https://')) {
      final transformed = _replaceS3WithCloudFront(key);
      debugPrint('S3VideoService: fallback URL: $transformed');
      final uri = Uri.tryParse(transformed);
      if (uri != null && uri.host.isNotEmpty) return uri;
    }

    debugPrint('S3VideoService: Failed to resolve URL for $key');
    return Uri();
  }

  bool isValidUri(Uri uri) {
    return uri.hasScheme &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  Future<String> _getOrFetchSignedUrl(String fileName) async {
    // Cached and still valid
    if (_urlCache.containsKey(fileName)) {
      final cached = _urlCache[fileName]!;
      if (_isUrlValidAndNotExpired(cached)) {
        return cached;
      }
      _urlCache.remove(fileName);
    }

    // Deduplicate concurrent requests for the same file
    if (_inflightRequests.containsKey(fileName)) {
      return _inflightRequests[fileName]!;
    }

    final future = _fetchFromApi(fileName).whenComplete(() {
      _inflightRequests.remove(fileName);
    });
    _inflightRequests[fileName] = future;
    return future;
  }

  Future<String> _fetchFromApi(String fileName) async {
    final response = await _apiClient.post(
      'videos/signed-url',
      data: {'file_name': fileName},
    );

    final url = response.data['url'] as String?;
    if (url == null || url.isEmpty) {
      throw Exception("Signed URL API returned no 'url' field");
    }

    _urlCache[fileName] = url;
    return url;
  }

  /// Replaces S3 bucket domains with the configured CloudFront domain.
  String _replaceS3WithCloudFront(String url) {
    if (_cloudFrontBaseUrl.isEmpty) return url;
    try {
      final uri = Uri.parse(url);
      if (uri.host.contains('.s3.') ||
          uri.host.contains('.s3-') ||
          uri.host.endsWith('.amazonaws.com')) {
        final path = uri.path;
        final cdnUri = Uri.tryParse('$_cloudFrontBaseUrl$path');
        if (cdnUri != null && cdnUri.host.isNotEmpty) {
          return cdnUri.toString();
        }
      }
    } catch (_) {}
    return url;
  }

  /// Extracts the file name from a full URL path or returns the input as-is.
  String _extractFileName(String urlOrName) {
    if (!urlOrName.startsWith('http://') && !urlOrName.startsWith('https://')) {
      return urlOrName;
    }
    final segments = urlOrName.split('/');
    return segments.isNotEmpty ? segments.last : '';
  }

  /// Checks if a signed URL is still within its valid window.
  ///
  /// Supports both CloudFront (?Expires=UNIX_SECONDS) and
  /// S3 pre-signed (?X-Amz-Expires=SECONDS) formats.
  bool _isUrlValidAndNotExpired(String url) {
    try {
      final uri = Uri.parse(url);

      // CloudFront signed URL: ?Expires=<unix-timestamp>
      final expiresStr = uri.queryParameters['Expires'];
      if (expiresStr != null) {
        final expires = int.tryParse(expiresStr);
        if (expires == null) return false;
        final remaining =
            expires - (DateTime.now().millisecondsSinceEpoch ~/ 1000);
        return remaining > _expirationBufferSeconds;
      }

      // S3 pre-signed URL: ?X-Amz-Expires=<seconds-from-now>
      // This is less precise client-side, so we give a generous buffer.
      final amzExpiresStr = uri.queryParameters['X-Amz-Expires'];
      if (amzExpiresStr != null) {
        final expiresIn = int.tryParse(amzExpiresStr);
        if (expiresIn == null) return false;
        // Assume signed about 30s ago as a conservative estimate
        return expiresIn > 120;
      }

      // No expiry param — assume permanent/public (fallback for plain CloudFront URLs)
      return true;
    } catch (_) {
      return false;
    }
  }
}
