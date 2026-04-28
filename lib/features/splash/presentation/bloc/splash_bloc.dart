import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// EVENTS
abstract class SplashEvent extends Equatable {
  const SplashEvent();
  @override
  List<Object> get props => [];
}

class StartSplashTimer extends SplashEvent {}

// STATES
abstract class SplashState extends Equatable {
  const SplashState();
  @override
  List<Object> get props => [];
}

class SplashInitial extends SplashState {}
class SplashLoading extends SplashState {}
class SplashCompleted extends SplashState {}

// BLOC
class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(SplashInitial()) {
    on<StartSplashTimer>(_onStartTimer);
  }

  Future<void> _onStartTimer(StartSplashTimer event, Emitter<SplashState> emit) async {
    emit(SplashLoading());
    // The user requested a 2800ms delay to match the React implementation
    await Future.delayed(const Duration(milliseconds: 2800));
    emit(SplashCompleted());
  }
}
