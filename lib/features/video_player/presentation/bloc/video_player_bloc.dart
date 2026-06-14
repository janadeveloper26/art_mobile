import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:art_mobile/features/video_player/data/s3_video_service.dart';
import 'video_player_event.dart';
import 'video_player_state.dart';

class VideoPlayerBloc extends Bloc<VideoPlayerEvent, VideoPlayerState> {
  final S3VideoService _s3VideoService;
  VideoPlayerController? _controller;

  VideoPlayerBloc({required S3VideoService s3VideoService})
      : _s3VideoService = s3VideoService,
        super(const VideoPlayerInitial()) {
    on<LoadVideo>(_onLoadVideo);
    on<PlayVideo>(_onPlayVideo);
    on<PauseVideo>(_onPauseVideo);
    on<ResumeVideo>(_onResumeVideo);
    on<SeekTo>(_onSeekTo);
    on<VideoEndedEvent>(_onVideoEnded);
    on<VideoErrorOccurred>(_onVideoError);
    on<DisposePlayer>(_onDisposePlayer);
    on<RetryVideo>(_onRetryVideo);
  }

  // ─── Handlers ──────────────────────────────────────────────────────────────

  Future<void> _onLoadVideo(
      LoadVideo event, Emitter<VideoPlayerState> emit) async {
    await _disposeController();
    emit(VideoPlayerLoading(lessonTitle: event.lessonTitle));

    final uri = await _s3VideoService.resolveVideoUri(event.videoUrl);
    if (!_s3VideoService.isValidUri(uri)) {
      emit(const VideoPlayerError(
        message: 'Unable to load this video.\n'
            'The video URL could not be resolved. Try again later.',
      ));
      return;
    }

    try {
      debugPrint('▶️ Video URL: $uri');
      final controller = VideoPlayerController.networkUrl(uri);
      _controller = controller;

      await controller.initialize().timeout(
        const Duration(seconds: 20),
        onTimeout: () => throw TimeoutException(
          'Video load timed out. Check your internet connection.',
        ),
      );

      controller.addListener(_onControllerUpdate);
      await controller.play();

      if (!isClosed) {
        emit(VideoPlaying(
          controller: controller,
          lessonTitle: event.lessonTitle,
          duration: controller.value.duration,
        ));
      }
    } on TimeoutException catch (e) {
      emit(VideoPlayerError(message: e.message ?? 'Video load timed out.'));
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('403') || msg.contains('401')) {
        emit(const VideoPlayerError(
          message: 'Video access denied (403).\n'
              'The URL may have expired. Tap Retry to refresh.',
        ));
      } else {
        emit(VideoPlayerError(message: 'Failed to load video.\n$msg'));
      }
    }
  }

  void _onPlayVideo(PlayVideo event, Emitter<VideoPlayerState> emit) {
    final ctrl = _controller;
    final s = state;
    if (ctrl == null || !ctrl.value.isInitialized || s is! VideoPlayerReady) {
      return;
    }
    ctrl.play();
    emit(VideoPlaying(
      controller: ctrl,
      lessonTitle: s.lessonTitle,
      duration: ctrl.value.duration,
    ));
  }

  void _onPauseVideo(PauseVideo event, Emitter<VideoPlayerState> emit) {
    final ctrl = _controller;
    final s = state;
    if (ctrl == null || !ctrl.value.isInitialized || s is! VideoPlayerReady) {
      return;
    }
    ctrl.pause();
    emit(VideoPaused(
      controller: ctrl,
      lessonTitle: s.lessonTitle,
      duration: ctrl.value.duration,
    ));
  }

  void _onResumeVideo(ResumeVideo event, Emitter<VideoPlayerState> emit) {
    final ctrl = _controller;
    final s = state;
    if (ctrl == null || !ctrl.value.isInitialized || s is! VideoPlayerReady) {
      return;
    }
    ctrl.play();
    emit(VideoPlaying(
      controller: ctrl,
      lessonTitle: s.lessonTitle,
      duration: ctrl.value.duration,
    ));
  }

  Future<void> _onSeekTo(SeekTo event, Emitter<VideoPlayerState> emit) async {
    final ctrl = _controller;
    final s = state;
    if (ctrl == null || !ctrl.value.isInitialized || s is! VideoPlayerReady) {
      return;
    }
    await ctrl.seekTo(event.position);
    // Preserve playing vs paused state after seek
    if (s is VideoPlaying) {
      emit(VideoPlaying(
          controller: ctrl,
          lessonTitle: s.lessonTitle,
          duration: ctrl.value.duration));
    } else {
      emit(VideoPaused(
          controller: ctrl,
          lessonTitle: s.lessonTitle,
          duration: ctrl.value.duration));
    }
  }

  void _onVideoEnded(
      VideoEndedEvent event, Emitter<VideoPlayerState> emit) {
    final ctrl = _controller;
    final s = state;
    if (ctrl == null || s is! VideoPlayerReady) return;
    ctrl.pause();
    // Seek to end so position display shows full duration
    ctrl.seekTo(ctrl.value.duration);
    emit(VideoCompleted(
      controller: ctrl,
      lessonTitle: s.lessonTitle,
      duration: ctrl.value.duration,
    ));
  }

  void _onVideoError(
      VideoErrorOccurred event, Emitter<VideoPlayerState> emit) {
    emit(VideoPlayerError(message: event.message));
  }

  Future<void> _onDisposePlayer(
      DisposePlayer event, Emitter<VideoPlayerState> emit) async {
    await _disposeController();
    emit(const VideoPlayerInitial());
  }

  // ─── Controller listener — completion & error detection only ───────────────
  // NOTE: real-time seek-bar position is read via ValueListenableBuilder in
  //       the UI, so we do NOT emit state on every frame here.
  void _onControllerUpdate() {
    final ctrl = _controller;
    if (ctrl == null || isClosed) return;

    final value = ctrl.value;

    if (value.hasError) {
      add(VideoErrorOccurred(
          value.errorDescription ?? 'Unknown playback error'));
      return;
    }

    // Detect natural end-of-video
    if (value.isInitialized &&
        !value.isPlaying &&
        value.duration > Duration.zero &&
        value.position >= value.duration) {
      if (state is VideoPlaying) {
        add(const VideoEndedEvent());
      }
    }
  }

  Future<void> _onRetryVideo(
      RetryVideo event, Emitter<VideoPlayerState> emit) async {
    await _onLoadVideo(
      LoadVideo(videoUrl: event.videoUrl, lessonTitle: event.lessonTitle),
      emit,
    );
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  Future<void> _disposeController() async {
    final ctrl = _controller;
    if (ctrl != null) {
      ctrl.removeListener(_onControllerUpdate);
      await ctrl.pause();
      await ctrl.dispose();
      _controller = null;
    }
  }

  @override
  Future<void> close() async {
    await _disposeController();
    return super.close();
  }
}
