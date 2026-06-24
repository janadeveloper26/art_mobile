import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/my_courses_model.dart';
import '../../../courses/domain/repositories/course_repository.dart';

// Events
abstract class MyCoursesEvent extends Equatable {
  const MyCoursesEvent();

  @override
  List<Object?> get props => [];
}

class LoadMyCourses extends MyCoursesEvent {}

class ToggleTab extends MyCoursesEvent {
  final int tabIndex;
  const ToggleTab(this.tabIndex);

  @override
  List<Object?> get props => [tabIndex];
}

// States
abstract class MyCoursesState extends Equatable {
  const MyCoursesState();

  @override
  List<Object?> get props => [];
}

class MyCoursesInitial extends MyCoursesState {}

class MyCoursesLoading extends MyCoursesState {}

class MyCoursesLoaded extends MyCoursesState {
  final MyCoursesResponse data;
  final int activeTab; // 0 for ongoing, 1 for completed

  const MyCoursesLoaded(this.data, this.activeTab);

  @override
  List<Object?> get props => [data, activeTab];

  MyCoursesLoaded copyWith({
    MyCoursesResponse? data,
    int? activeTab,
  }) {
    return MyCoursesLoaded(
      data ?? this.data,
      activeTab ?? this.activeTab,
    );
  }
}

class MyCoursesError extends MyCoursesState {
  final String message;
  const MyCoursesError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class MyCoursesBloc extends Bloc<MyCoursesEvent, MyCoursesState> {
  final ICourseRepository repository;

  MyCoursesBloc(this.repository) : super(MyCoursesInitial()) {
    on<LoadMyCourses>((event, emit) async {
      emit(MyCoursesLoading());
      try {
        final data = await repository.getMyCourses();
        emit(MyCoursesLoaded(data, 0));
      } catch (e) {
        emit(const MyCoursesError('Failed to load your courses'));
      }
    });

    on<ToggleTab>((event, emit) {
      if (state is MyCoursesLoaded) {
        final currentState = state as MyCoursesLoaded;
        emit(currentState.copyWith(activeTab: event.tabIndex));
      }
    });
  }
}
