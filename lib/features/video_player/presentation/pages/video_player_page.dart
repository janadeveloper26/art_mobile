import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:video_player/video_player.dart';
import 'package:art_mobile/core/theme/theme_colors.dart';
import 'package:art_mobile/core/theme/theme_manager.dart';
import 'package:art_mobile/core/config/service_locator.dart';
import 'package:art_mobile/features/courses/data/models/course_model.dart';
import 'package:art_mobile/features/courses/data/mock_course_service.dart';
import 'package:art_mobile/features/video_player/data/s3_video_service.dart';
import '../bloc/video_player_bloc.dart';
import '../bloc/video_player_event.dart';
import '../bloc/video_player_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Entry point — provides the BLoC
// ─────────────────────────────────────────────────────────────────────────────

class VideoPlayerPage extends StatelessWidget {
  final String courseId;
  final String videoId;
  final String? videoUrl;

  const VideoPlayerPage({
    super.key,
    required this.courseId,
    required this.videoId,
    this.videoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VideoPlayerBloc(s3VideoService: sl<S3VideoService>()),
      child: _VideoPlayerView(
        courseId: courseId,
        videoId: videoId,
        overrideUrl: videoUrl,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal stateful view
// ─────────────────────────────────────────────────────────────────────────────

class _VideoPlayerView extends StatefulWidget {
  final String courseId;
  final String videoId;
  final String? overrideUrl;

  const _VideoPlayerView({
    required this.courseId,
    required this.videoId,
    this.overrideUrl,
  });

  @override
  State<_VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<_VideoPlayerView>
    with WidgetsBindingObserver {
  CourseDetail? _courseDetail;
  bool _courseLoading = true;
  String? _courseError;
  CourseLesson? _currentLesson;
  String _currentVideoUrl = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadCourseAndPlay();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState appState) {
    if (appState == AppLifecycleState.paused ||
        appState == AppLifecycleState.inactive) {
      context.read<VideoPlayerBloc>().add(const PauseVideo());
    }
  }

  Future<void> _loadCourseAndPlay() async {
    try {
      final detail =
          await sl<ICourseRepository>().getCourseDetail(widget.courseId);
      if (!mounted) return;
      setState(() {
        _courseDetail = detail;
        _courseLoading = false;
      });
      _playLesson(_resolveLesson(detail));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _courseError = e.toString();
        _courseLoading = false;
      });
    }
  }

  CourseLesson? _resolveLesson(CourseDetail detail) {
    final all = detail.curriculum.expand((s) => s.lessons).toList();
    if (all.isEmpty) return null;
    try {
      return all.firstWhere((l) => l.id == widget.videoId);
    } catch (_) {
      return all.first;
    }
  }

  void _playLesson(CourseLesson? lesson) {
    if (lesson == null) return;
    final url = (widget.overrideUrl?.isNotEmpty == true)
        ? widget.overrideUrl!
        : lesson.videoUrl;
    setState(() {
      _currentLesson = lesson;
      _currentVideoUrl = url;
    });
    context
        .read<VideoPlayerBloc>()
        .add(LoadVideo(videoUrl: url, lessonTitle: lesson.title));
  }

  void _switchLesson(CourseLesson lesson) {
    if (lesson.id == _currentLesson?.id) return;
    _playLesson(lesson);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = sl<ThemeManager>().isDarkMode;
    final bg = isDark ? ThemeColors.backgroundDark : const Color(0xFFF7F7FA);

    if (_courseLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Color(0xFF8B5CF6)),
              const SizedBox(height: 16),
              Text('Loading course…',
                  style: GoogleFonts.outfit(
                      color: Colors.white60, fontSize: 14)),
            ],
          ),
        ),
      );
    }

    if (_courseError != null || _courseDetail == null) {
      return Scaffold(
        backgroundColor: bg,
        appBar: _appBar(isDark),
        body: _FullPageError(
            message: _courseError ?? 'Course not found.', isDark: isDark),
      );
    }

    final allLessons =
        _courseDetail!.curriculum.expand((s) => s.lessons).toList();

    return Scaffold(
      backgroundColor: bg,
      appBar: _appBar(isDark),
      body: Column(
        children: [
          _VideoArea(
            isDark: isDark,
            retryUrl: _currentVideoUrl.isNotEmpty ? _currentVideoUrl : null,
            retryTitle: _currentLesson?.title,
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _LessonHeader(
                    lesson: _currentLesson,
                    courseDetail: _courseDetail!,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 28),
                  _SectionDivider(label: 'LESSONS', isDark: isDark),
                  const SizedBox(height: 12),
                  ...allLessons.map((l) => _LessonListItem(
                        lesson: l,
                        isActive: l.id == _currentLesson?.id,
                        isDark: isDark,
                        onTap: () => _switchLesson(l),
                      )),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  AppBar _appBar(bool isDark) => AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'NOW PLAYING',
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white70 : Colors.grey.shade600,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.4,
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Video area: switches between states
// ─────────────────────────────────────────────────────────────────────────────

class _VideoArea extends StatelessWidget {
  final bool isDark;
  final String? retryUrl;
  final String? retryTitle;
  const _VideoArea({
    required this.isDark,
    this.retryUrl,
    this.retryTitle,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.black,
        child: BlocBuilder<VideoPlayerBloc, VideoPlayerState>(
          builder: (context, state) {
            if (state is VideoPlayerInitial) {
              return const _BlankPlaceholder();
            }
            if (state is VideoPlayerLoading) {
              return _LoadingOverlay(lessonTitle: state.lessonTitle);
            }
            if (state is VideoPlayerError) {
              return _ErrorOverlay(
                message: state.message,
                onRetry: (retryUrl != null && retryTitle != null)
                    ? () => context.read<VideoPlayerBloc>().add(
                          RetryVideo(
                            videoUrl: retryUrl!,
                            lessonTitle: retryTitle!,
                          ),
                        )
                    : null,
              );
            }
            if (state is VideoPlayerReady) {
              return _ActivePlayer(readyState: state);
            }
            return const _BlankPlaceholder();
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Active player with custom overlays
// ─────────────────────────────────────────────────────────────────────────────

class _ActivePlayer extends StatefulWidget {
  final VideoPlayerReady readyState;
  const _ActivePlayer({required this.readyState});

  @override
  State<_ActivePlayer> createState() => _ActivePlayerState();
}

class _ActivePlayerState extends State<_ActivePlayer> {
  bool _showControls = true;

  void _toggleControls() => setState(() => _showControls = !_showControls);

  @override
  Widget build(BuildContext context) {
    // Rebuild when BLoC emits to track playing/paused/completed transitions
    return BlocBuilder<VideoPlayerBloc, VideoPlayerState>(
      builder: (context, state) {
        final readyState =
            state is VideoPlayerReady ? state : widget.readyState;
        final isCompleted = readyState is VideoCompleted;
        final isPlaying = readyState is VideoPlaying;

        return GestureDetector(
          onTap: _toggleControls,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Raw video output
              Center(child: VideoPlayer(readyState.controller)),

              // Completion overlay (no auto-loop)
              if (isCompleted)
                _CompletedOverlay(
                  lessonTitle: readyState.lessonTitle,
                  duration: readyState.duration,
                ),

              // Controls overlay (hidden on completion)
              if (!isCompleted && _showControls)
                ValueListenableBuilder<VideoPlayerValue>(
                  valueListenable: readyState.controller,
                  builder: (context, value, _) => _ControlsOverlay(
                    isPlaying: isPlaying,
                    position: value.position,
                    duration: value.duration,
                    buffered: value.buffered,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Controls overlay — live position via ValueListenableBuilder (0 BLoC emits)
// ─────────────────────────────────────────────────────────────────────────────

class _ControlsOverlay extends StatelessWidget {
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final List<DurationRange> buffered;

  const _ControlsOverlay({
    required this.isPlaying,
    required this.position,
    required this.duration,
    required this.buffered,
  });

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  double get _progress =>
      duration.inMilliseconds > 0
          ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
          : 0.0;

  double get _bufferedFraction {
    if (buffered.isEmpty || duration.inMilliseconds == 0) return 0.0;
    return (buffered.last.end.inMilliseconds / duration.inMilliseconds)
        .clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<VideoPlayerBloc>();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.55),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withValues(alpha: 0.80),
          ],
          stops: const [0.0, 0.25, 0.60, 1.0],
        ),
      ),
      child: Column(
        children: [
          const Spacer(),

          // Centre play / pause button
          Center(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => isPlaying
                  ? bloc.add(const PauseVideo())
                  : bloc.add(const ResumeVideo()),
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.55),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                ),
                child: Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),

          const Spacer(),

          // Bottom: seek bar + time labels
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // Buffered track background
                    Container(
                      height: 3,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                      child: FractionallySizedBox(
                        widthFactor: _bufferedFraction,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: Colors.white.withValues(alpha: 0.38),
                          ),
                        ),
                      ),
                    ),
                    // Seek slider (played position)
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: const Color(0xFF8B5CF6),
                        inactiveTrackColor: Colors.transparent,
                        thumbColor: const Color(0xFF8B5CF6),
                        overlayColor: const Color(0xFF8B5CF6)
                            .withValues(alpha: 0.25),
                        thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 7),
                        overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 14),
                        trackHeight: 3,
                      ),
                      child: Slider(
                        value: _progress,
                        onChanged: (v) {
                          final ms = (v * duration.inMilliseconds).round();
                          bloc.add(SeekTo(Duration(milliseconds: ms)));
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_fmt(position),
                        style: GoogleFonts.outfit(
                            color: Colors.white70, fontSize: 11)),
                    Text(_fmt(duration),
                        style: GoogleFonts.outfit(
                            color: Colors.white70, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Completion overlay — shown when video ends naturally (no auto-loop)
// ─────────────────────────────────────────────────────────────────────────────

class _CompletedOverlay extends StatelessWidget {
  final String lessonTitle;
  final Duration duration;

  const _CompletedOverlay({
    required this.lessonTitle,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.78),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            // Glowing check icon
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFFAB47BC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        const Color(0xFF8B5CF6).withValues(alpha: 0.5),
                    blurRadius: 28,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(Icons.check_rounded,
                  color: Colors.white, size: 38),
            ),
            const SizedBox(height: 20),
            Text(
              'Lesson Complete!',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              lessonTitle,
              style: GoogleFonts.outfit(
                  color: Colors.white54, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            // Replay button
            GestureDetector(
              onTap: () {
                final bloc = context.read<VideoPlayerBloc>();
                bloc.add(const SeekTo(Duration.zero));
                bloc.add(const PlayVideo());
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 13),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFFAB47BC)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.replay_rounded,
                        color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Replay Lesson',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loading overlay
// ─────────────────────────────────────────────────────────────────────────────

class _LoadingOverlay extends StatelessWidget {
  final String lessonTitle;
  const _LoadingOverlay({required this.lessonTitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          const SizedBox(
            width: 42,
            height: 42,
            child: CircularProgressIndicator(
              color: Color(0xFF8B5CF6),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text('Buffering…',
              style: GoogleFonts.outfit(
                  color: Colors.white60, fontSize: 14)),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              lessonTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(
                  color: Colors.white38, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error overlay (inside 16:9 box)
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorOverlay extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const _ErrorOverlay({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            const Icon(LucideIcons.videoOff,
                color: Colors.white38, size: 44),
            const SizedBox(height: 12),
            Text(
              'Could not play video',
              style: GoogleFonts.outfit(
                color: Colors.white70,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: GoogleFonts.outfit(
                  color: Colors.white38, fontSize: 11),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              GestureDetector(
                onTap: onRetry,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.refresh_rounded,
                          color: Colors.white70, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Retry',
                        style: GoogleFonts.outfit(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Blank placeholder (before any video loads)
// ─────────────────────────────────────────────────────────────────────────────

class _BlankPlaceholder extends StatelessWidget {
  const _BlankPlaceholder();

  @override
  Widget build(BuildContext context) => const Center(
        child: Icon(LucideIcons.play, color: Color(0x1FFFFFFF), size: 56),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Full-page error (course load failure)
// ─────────────────────────────────────────────────────────────────────────────

class _FullPageError extends StatelessWidget {
  final String message;
  final bool isDark;
  const _FullPageError({required this.message, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.alertCircle,
                color: Color(0xFF8B5CF6), size: 52),
            const SizedBox(height: 16),
            Text(
              'Unable to load content',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                  fontSize: 13, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Lesson header with live BLoC state badge
// ─────────────────────────────────────────────────────────────────────────────

class _LessonHeader extends StatelessWidget {
  final CourseLesson? lesson;
  final CourseDetail courseDetail;
  final bool isDark;

  const _LessonHeader({
    required this.lesson,
    required this.courseDetail,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Live state badge
        BlocBuilder<VideoPlayerBloc, VideoPlayerState>(
          builder: (context, state) {
            String label = '';
            Color color = Colors.transparent;

            if (state is VideoPlaying) {
              label = '● PLAYING';
              color = const Color(0xFF10B981);
            } else if (state is VideoPaused) {
              label = '⏸ PAUSED';
              color = const Color(0xFFF59E0B);
            } else if (state is VideoCompleted) {
              label = '✓ COMPLETED';
              color = const Color(0xFF8B5CF6);
            }

            if (label.isEmpty) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withValues(alpha: 0.35)),
                ),
                child: Text(
                  label,
                  style: GoogleFonts.outfit(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            );
          },
        ),

        Text(
          lesson?.title ?? courseDetail.title,
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            height: 1.25,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          courseDetail.description,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.outfit(
            fontSize: 13,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section divider
// ─────────────────────────────────────────────────────────────────────────────

class _SectionDivider extends StatelessWidget {
  final String label;
  final bool isDark;
  const _SectionDivider({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF8B5CF6),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Divider(
            color: isDark ? Colors.white12 : Colors.grey.shade200,
            thickness: 1,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Lesson list item
// ─────────────────────────────────────────────────────────────────────────────

class _LessonListItem extends StatelessWidget {
  final CourseLesson lesson;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  const _LessonListItem({
    required this.lesson,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  static const _purple = Color(0xFF8B5CF6);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isActive
                  ? _purple.withValues(alpha: 0.08)
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : Colors.white),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isActive
                    ? _purple.withValues(alpha: 0.25)
                    : Colors.transparent,
              ),
              boxShadow: isActive || isDark
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive
                        ? _purple
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.12)
                            : const Color(0xFFF4F0FF)),
                  ),
                  child: Icon(
                    isActive
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: isActive ? Colors.white : _purple,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson.title,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: isActive
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: isActive
                              ? _purple
                              : (isDark
                                  ? Colors.grey.shade300
                                  : const Color(0xFF1A1A1A)),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        lesson.duration,
                        style: GoogleFonts.outfit(
                            fontSize: 11,
                            color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
                if (lesson.isCompleted)
                  const Icon(Icons.check_circle_rounded,
                      color: _purple, size: 20)
                else if (lesson.isPreview)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'FREE',
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF10B981),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
