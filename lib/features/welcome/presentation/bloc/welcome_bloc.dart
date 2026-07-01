import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// EVENTS
abstract class WelcomeEvent extends Equatable {
  const WelcomeEvent();
  @override
  List<Object> get props => [];
}

class GetStartedPressed extends WelcomeEvent {}

class AlreadyHaveAccountPressed extends WelcomeEvent {}

// STATES
abstract class WelcomeState extends Equatable {
  const WelcomeState();
  @override
  List<Object> get props => [];
}

class WelcomeInitial extends WelcomeState {}

class NavigateToOnboarding extends WelcomeState {}

class NavigateToLogin extends WelcomeState {}

// BLOC
class WelcomeBloc extends Bloc<WelcomeEvent, WelcomeState> {
  WelcomeBloc() : super(WelcomeInitial()) {
    on<GetStartedPressed>((event, emit) => emit(NavigateToOnboarding()));
    on<AlreadyHaveAccountPressed>((event, emit) => emit(NavigateToLogin()));
  }
}
