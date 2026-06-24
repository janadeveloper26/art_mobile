import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/explore_model.dart';
import '../../../domain/repositories/course_repository.dart';

// Events
abstract class ExploreEvent extends Equatable {
  const ExploreEvent();

  @override
  List<Object?> get props => [];
}

class LoadExploreData extends ExploreEvent {}

class SearchCourses extends ExploreEvent {
  final String query;
  const SearchCourses(this.query);

  @override
  List<Object?> get props => [query];
}

class ChangeCategory extends ExploreEvent {
  final String category;
  const ChangeCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class ChangeFilter extends ExploreEvent {
  final String filter;
  const ChangeFilter(this.filter);

  @override
  List<Object?> get props => [filter];
}

// States
abstract class ExploreState extends Equatable {
  const ExploreState();

  @override
  List<Object?> get props => [];
}

class ExploreInitial extends ExploreState {}

class ExploreLoading extends ExploreState {}

class ExploreLoaded extends ExploreState {
  final ExploreResponse data;
  final String query;
  final String activeCategory;
  final String activeFilter;

  const ExploreLoaded({
    required this.data,
    this.query = '',
    this.activeCategory = 'All',
    this.activeFilter = 'All',
  });

  @override
  List<Object?> get props => [data, query, activeCategory, activeFilter];

  ExploreLoaded copyWith({
    ExploreResponse? data,
    String? query,
    String? activeCategory,
    String? activeFilter,
  }) {
    return ExploreLoaded(
      data: data ?? this.data,
      query: query ?? this.query,
      activeCategory: activeCategory ?? this.activeCategory,
      activeFilter: activeFilter ?? this.activeFilter,
    );
  }
}

class ExploreError extends ExploreState {
  final String message;
  const ExploreError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class ExploreBloc extends Bloc<ExploreEvent, ExploreState> {
  final ICourseRepository repository;

  ExploreBloc(this.repository) : super(ExploreInitial()) {
    on<LoadExploreData>((event, emit) async {
      emit(ExploreLoading());
      try {
        final data = await repository.getExploreData();
        emit(ExploreLoaded(data: data));
      } catch (e) {
        emit(const ExploreError('Failed to load explore data'));
      }
    });

    on<SearchCourses>((event, emit) async {
      if (state is ExploreLoaded) {
        final currentState = state as ExploreLoaded;
        emit(ExploreLoading());
        try {
          final data = await repository.getExploreData(
            query: event.query,
            category: currentState.activeCategory,
            filter: currentState.activeFilter,
          );
          emit(currentState.copyWith(data: data, query: event.query));
        } catch (e) {
          emit(const ExploreError('Search failed'));
        }
      }
    });

    on<ChangeCategory>((event, emit) async {
      if (state is ExploreLoaded) {
        final currentState = state as ExploreLoaded;
        emit(ExploreLoading());
        try {
          final data = await repository.getExploreData(
            query: currentState.query,
            category: event.category,
            filter: currentState.activeFilter,
          );
          emit(currentState.copyWith(data: data, activeCategory: event.category));
        } catch (e) {
          emit(const ExploreError('Category change failed'));
        }
      }
    });

    on<ChangeFilter>((event, emit) async {
      if (state is ExploreLoaded) {
        final currentState = state as ExploreLoaded;
        emit(ExploreLoading());
        try {
          final data = await repository.getExploreData(
            query: currentState.query,
            category: currentState.activeCategory,
            filter: event.filter,
          );
          emit(currentState.copyWith(data: data, activeFilter: event.filter));
        } catch (e) {
          emit(const ExploreError('Filter change failed'));
        }
      }
    });
  }
}
