import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// MODELS
class OnboardingSlide {
  final int id;
  final String emoji;
  final String title;
  final String subtitle;
  final String description;
  final List<OnboardingStat> stats;
  final List<int> gradientColors; // Store as hex integers
  final int accentColor;

  const OnboardingSlide({
    required this.id,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.stats,
    required this.gradientColors,
    required this.accentColor,
  });
}

class OnboardingStat {
  final String value;
  final String label;
  const OnboardingStat({required this.value, required this.label});
}

// EVENTS
abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();
  @override
  List<Object> get props => [];
}

class LoadOnboardingSlides extends OnboardingEvent {}
class NextSlidePressed extends OnboardingEvent {}
class PreviousSlidePressed extends OnboardingEvent {}
class SkipPressed extends OnboardingEvent {}
class SetSlideIndex extends OnboardingEvent {
  final int index;
  const SetSlideIndex(this.index);
  @override
  List<Object> get props => [index];
}

// STATES
class OnboardingState extends Equatable {
  final int currentIndex;
  final List<OnboardingSlide> slides;
  final bool isCompleted;

  const OnboardingState({
    this.currentIndex = 0,
    this.slides = const [],
    this.isCompleted = false,
  });

  OnboardingState copyWith({
    int? currentIndex,
    List<OnboardingSlide>? slides,
    bool? isCompleted,
  }) {
    return OnboardingState(
      currentIndex: currentIndex ?? this.currentIndex,
      slides: slides ?? this.slides,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object> get props => [currentIndex, slides, isCompleted];
}

// BLOC
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc() : super(const OnboardingState()) {
    on<LoadOnboardingSlides>(_onLoadSlides);
    on<NextSlidePressed>(_onNextSlide);
    on<PreviousSlidePressed>(_onPreviousSlide);
    on<SetSlideIndex>((event, emit) => emit(state.copyWith(currentIndex: event.index)));
    on<SkipPressed>((event, emit) => emit(state.copyWith(isCompleted: true)));
  }

  void _onLoadSlides(LoadOnboardingSlides event, Emitter<OnboardingState> emit) {
    final slides = [
      const OnboardingSlide(
        id: 0,
        emoji: "🪡",
        title: "Learn Aari Embroidery",
        subtitle: "from India's Best",
        description: "Master the ancient art of Aari embroidery with structured video courses taught by certified professionals. From chain stitches to complex bridal designs.",
        gradientColors: [0xFF4A0072, 0xFF6A1B9A],
        accentColor: 0xFFCE93D8,
        stats: [
          OnboardingStat(value: "50+", label: "Aari Courses"),
          OnboardingStat(value: "10K+", label: "Students"),
          OnboardingStat(value: "4.8★", label: "Avg Rating"),
        ],
      ),
      const OnboardingSlide(
        id: 1,
        emoji: "✂️",
        title: "Professional Tailoring",
        subtitle: "Step by Step",
        description: "Learn garment construction, pattern making, and professional stitching techniques. Create stunning Indian wear — blouses, salwars, anarkalis and more.",
        gradientColors: [0xFF1A237E, 0xFF4527A0],
        accentColor: 0xFF9FA8DA,
        stats: [
          OnboardingStat(value: "40+", label: "Tailoring Courses"),
          OnboardingStat(value: "95%", label: "Completion Rate"),
          OnboardingStat(value: "Free", label: "Certificates"),
        ],
      ),
      const OnboardingSlide(
        id: 2,
        emoji: "🏆",
        title: "Earn & Grow",
        subtitle: "Build Your Career",
        description: "Turn your passion into a profession. Get certified, build your portfolio, and join a thriving community of skilled artisans and designers across India.",
        gradientColors: [0xFF560027, 0xFF880E4F],
        accentColor: 0xFFF48FB1,
        stats: [
          OnboardingStat(value: "₹500-2K", label: "Avg Income/Day"),
          OnboardingStat(value: "200+", label: "Success Stories"),
          OnboardingStat(value: "Live", label: "Community"),
        ],
      ),
    ];
    emit(state.copyWith(slides: slides));
  }

  void _onNextSlide(NextSlidePressed event, Emitter<OnboardingState> emit) {
    if (state.currentIndex < state.slides.length - 1) {
      emit(state.copyWith(currentIndex: state.currentIndex + 1));
    } else {
      emit(state.copyWith(isCompleted: true));
    }
  }

  void _onPreviousSlide(PreviousSlidePressed event, Emitter<OnboardingState> emit) {
    if (state.currentIndex > 0) {
      emit(state.copyWith(currentIndex: state.currentIndex - 1));
    }
  }
}
