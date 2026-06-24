import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/course_model.dart';
import '../../../domain/repositories/course_repository.dart';

// Events
abstract class CourseDetailEvent extends Equatable {
  const CourseDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadCourseDetail extends CourseDetailEvent {
  final String courseId;
  const LoadCourseDetail(this.courseId);

  @override
  List<Object?> get props => [courseId];
}

class ToggleWishlist extends CourseDetailEvent {}

class SelectTab extends CourseDetailEvent {
  final int tabIndex;
  const SelectTab(this.tabIndex);

  @override
  List<Object?> get props => [tabIndex];
}

class ToggleSection extends CourseDetailEvent {
  final String sectionId;
  const ToggleSection(this.sectionId);

  @override
  List<Object?> get props => [sectionId];
}

// States
abstract class CourseDetailState extends Equatable {
  const CourseDetailState();

  @override
  List<Object?> get props => [];
}

class CourseDetailInitial extends CourseDetailState {}

class CourseDetailLoading extends CourseDetailState {}

class CourseDetailLoaded extends CourseDetailState {
  final CourseDetail course;
  final bool isWishlisted;
  final int activeTab;
  final List<String> expandedSections;

  const CourseDetailLoaded({
    required this.course,
    required this.isWishlisted,
    required this.activeTab,
    required this.expandedSections,
  });

  @override
  List<Object?> get props => [course, isWishlisted, activeTab, expandedSections];

  CourseDetailLoaded copyWith({
    CourseDetail? course,
    bool? isWishlisted,
    int? activeTab,
    List<String>? expandedSections,
  }) {
    return CourseDetailLoaded(
      course: course ?? this.course,
      isWishlisted: isWishlisted ?? this.isWishlisted,
      activeTab: activeTab ?? this.activeTab,
      expandedSections: expandedSections ?? this.expandedSections,
    );
  }
}

class CourseDetailError extends CourseDetailState {
  final String message;
  const CourseDetailError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class CourseDetailBloc extends Bloc<CourseDetailEvent, CourseDetailState> {
  final ICourseRepository repository;

  CourseDetailBloc(this.repository) : super(CourseDetailInitial()) {
    on<LoadCourseDetail>((event, emit) async {
      emit(CourseDetailLoading());
      try {
        final course = await repository.getCourseDetail(event.courseId);
        emit(CourseDetailLoaded(
          course: course,
          isWishlisted: course.isWishlisted,
          activeTab: 0,
          expandedSections: const ['s1'],
        ));
      } catch (e) {
        emit(const CourseDetailError('Failed to load course details'));
      }
    });

    on<ToggleWishlist>((event, emit) {
      if (state is CourseDetailLoaded) {
        final currentState = state as CourseDetailLoaded;
        emit(currentState.copyWith(isWishlisted: !currentState.isWishlisted));
      }
    });

    on<SelectTab>((event, emit) {
      if (state is CourseDetailLoaded) {
        final currentState = state as CourseDetailLoaded;
        emit(currentState.copyWith(activeTab: event.tabIndex));
      }
    });

    on<ToggleSection>((event, emit) {
      if (state is CourseDetailLoaded) {
        final currentState = state as CourseDetailLoaded;
        final expanded = List<String>.from(currentState.expandedSections);
        if (expanded.contains(event.sectionId)) {
          expanded.remove(event.sectionId);
        } else {
          expanded.add(event.sectionId);
        }
        emit(currentState.copyWith(expandedSections: expanded));
      }
    });
  }
}
