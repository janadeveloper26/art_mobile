import 'package:equatable/equatable.dart';

abstract class VideoPlayerEvent extends Equatable {
  const VideoPlayerEvent();

  @override
  List<Object?> get props => [];
}

/// Load and initialise the controller for [videoUrl].
class LoadVideo extends VideoPlayerEvent {
  final String videoUrl;
  final String lessonTitle;

  const LoadVideo({required this.videoUrl, required this.lessonTitle});

  @override
  List<Object?> get props => [videoUrl, lessonTitle];
}

/// Start playback (used after seek-to-zero + replay).
class PlayVideo extends VideoPlayerEvent {
  const PlayVideo();
}

/// Pause playback.
class PauseVideo extends VideoPlayerEvent {
  const PauseVideo();
}

/// Resume a paused video.
class ResumeVideo extends VideoPlayerEvent {
  const ResumeVideo();
}

/// Seek to a specific position.
class SeekTo extends VideoPlayerEvent {
  final Duration position;

  const SeekTo(this.position);

  @override
  List<Object?> get props => [position];
}

/// Fired internally by the controller listener when the video reaches its end.
/// Named [VideoEndedEvent] to avoid collision with the [VideoCompleted] state.
class VideoEndedEvent extends VideoPlayerEvent {
  const VideoEndedEvent();
}

/// Fired when the controller emits an error.
class VideoErrorOccurred extends VideoPlayerEvent {
  final String message;

  const VideoErrorOccurred(this.message);

  @override
  List<Object?> get props => [message];
}

/// Dispose the current controller (e.g. when switching lessons).
class DisposePlayer extends VideoPlayerEvent {
  const DisposePlayer();
}
