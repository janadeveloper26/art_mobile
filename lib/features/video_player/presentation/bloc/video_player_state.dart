import 'package:equatable/equatable.dart';
import 'package:video_player/video_player.dart';

abstract class VideoPlayerState extends Equatable {
  const VideoPlayerState();

  @override
  List<Object?> get props => [];
}

/// Nothing loaded yet.
class VideoPlayerInitial extends VideoPlayerState {
  const VideoPlayerInitial();
}

/// Controller is initialising.
class VideoPlayerLoading extends VideoPlayerState {
  final String lessonTitle;
  const VideoPlayerLoading({required this.lessonTitle});

  @override
  List<Object?> get props => [lessonTitle];
}

/// Shared base for all states where the controller is ready.
/// The UI reads [controller.value.position] live via [ValueListenableBuilder]
/// so we only store [duration] here for the completed-overlay label.
abstract class VideoPlayerReady extends VideoPlayerState {
  final VideoPlayerController controller;
  final String lessonTitle;
  final Duration duration;

  const VideoPlayerReady({
    required this.controller,
    required this.lessonTitle,
    required this.duration,
  });

  @override
  List<Object?> get props => [controller, lessonTitle, duration];
}

/// Video is actively playing.
class VideoPlaying extends VideoPlayerReady {
  const VideoPlaying({
    required super.controller,
    required super.lessonTitle,
    required super.duration,
  });
}

/// Video is paused (user action or app lifecycle).
class VideoPaused extends VideoPlayerReady {
  const VideoPaused({
    required super.controller,
    required super.lessonTitle,
    required super.duration,
  });
}

/// Video reached its natural end — no auto-loop.
class VideoCompleted extends VideoPlayerReady {
  const VideoCompleted({
    required super.controller,
    required super.lessonTitle,
    required super.duration,
  });
}

/// An error occurred (bad URL, network failure, codec error).
class VideoPlayerError extends VideoPlayerState {
  final String message;
  const VideoPlayerError({required this.message});

  @override
  List<Object?> get props => [message];
}
