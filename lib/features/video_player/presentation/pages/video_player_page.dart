import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/theme/theme_manager.dart';
import '../../../../core/config/service_locator.dart';
import '../../../courses/data/models/course_model.dart';
import '../../../courses/data/mock_course_service.dart';

class VideoPlayerPage extends StatefulWidget {
  final String videoId;
  final String? videoUrl;

  const VideoPlayerPage({
    super.key, 
    required this.videoId,
    this.videoUrl,
  });

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> with WidgetsBindingObserver {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  CourseDetail? _courseDetail;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _videoPlayerController.pause();
    }
  }

  Future<void> _loadData() async {
    _courseDetail = await sl<ICourseRepository>().getCourseDetail('1');
    await _initializePlayer();
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _initializePlayer() async {
    final allLessons = _courseDetail?.curriculum.expand((s) => s.lessons).toList() ?? [];
    String url = widget.videoUrl ?? 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';
    
    if (allLessons.isNotEmpty) {
      try {
        final lesson = allLessons.firstWhere((l) => l.id == widget.videoId);
        url = lesson.videoUrl;
      } catch (_) {
        url = allLessons[0].videoUrl;
      }
    }
    
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url));
    await _videoPlayerController.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
      aspectRatio: _videoPlayerController.value.aspectRatio,
      materialProgressColors: ChewieProgressColors(
        playedColor: const Color(0xFF6A1B9A),
        handleColor: const Color(0xFF6A1B9A),
        backgroundColor: Colors.white.withOpacity(0.2),
        bufferedColor: Colors.white.withOpacity(0.3),
      ),
      placeholder: Container(
        color: Colors.black,
        child: const Center(child: CircularProgressIndicator(color: Color(0xFF6A1B9A))),
      ),
    );
    if (mounted) setState(() {});
  }



  @override
  Widget build(BuildContext context) {
    final isDark = sl<ThemeManager>().isDarkMode;
    
    if (_isLoading || _courseDetail == null) {
      return Scaffold(
        backgroundColor: isDark ? ThemeColors.backgroundDark : Colors.black,
        body: const Center(child: CircularProgressIndicator(color: Color(0xFF6A1B9A))),
      );
    }

    final allLessons = _courseDetail!.curriculum.expand((s) => s.lessons).toList();
    CourseLesson? currentLesson;
    try {
      currentLesson = allLessons.firstWhere((l) => l.id == widget.videoId);
    } catch (_) {
      currentLesson = allLessons.isNotEmpty ? allLessons[0] : null;
    }

    return Scaffold(
      backgroundColor: isDark ? ThemeColors.backgroundDark : const Color(0xFFFBFBFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'NOW PLAYING',
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white70 : Colors.grey.shade600,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: Colors.black,
                child: _chewieController != null && _chewieController!.videoPlayerController.value.isInitialized
                    ? Chewie(controller: _chewieController!)
                    : const Center(child: CircularProgressIndicator(color: Color(0xFF6A1B9A))),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentLesson?.title ?? _courseDetail!.title,
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _courseDetail!.description,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      height: 1.6,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  _buildTabs(isDark),
                  const SizedBox(height: 24),
                  
                  ...allLessons.map((lesson) {
                    final isPlaying = lesson.id == currentLesson?.id;
                    return _buildLessonItem(
                      lesson, 
                      isPlaying: isPlaying,
                      isDark: isDark,
                      onTap: () {
                        if (!isPlaying) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VideoPlayerPage(videoId: lesson.id),
                            ),
                          );
                        }
                      },
                    );
                  }).toList(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs(bool isDark) {
    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade200, width: 1))),
      child: Row(
        children: [
          Text('LESSONS', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF6A1B9A), letterSpacing: 1)),
          const SizedBox(width: 32),
          Text('RESOURCES', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildLessonItem(CourseLesson lesson, {required bool isPlaying, required bool isDark, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isPlaying 
              ? const Color(0xFF6A1B9A).withOpacity(0.08) 
              : (isDark ? Colors.white.withOpacity(0.03) : Colors.white),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isPlaying ? const Color(0xFF6A1B9A).withOpacity(0.2) : Colors.transparent),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isPlaying ? const Color(0xFF6A1B9A) : (isDark ? Colors.white12 : const Color(0xFFF8F6FB)),
                  shape: BoxShape.circle,
                ),
                child: Icon(isPlaying ? LucideIcons.pause : LucideIcons.play, color: isPlaying ? Colors.white : const Color(0xFF6A1B9A), size: 16),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: isPlaying ? FontWeight.bold : FontWeight.w500,
                        color: isPlaying ? const Color(0xFF6A1B9A) : (isDark ? Colors.grey.shade300 : const Color(0xFF1A1A1A)),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(lesson.duration, style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey.shade500)),
                  ],
                ),
              ),
              if (lesson.isCompleted) const Icon(LucideIcons.checkCircle2, color: Color(0xFF6A1B9A), size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
