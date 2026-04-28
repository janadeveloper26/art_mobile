import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/subscription_model.dart';
import '../../data/mock_subscription_repository.dart';

// Events
abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();

  @override
  List<Object?> get props => [];
}

class LoadSubscriptionData extends SubscriptionEvent {}

class SelectPlan extends SubscriptionEvent {
  final String planId;
  const SelectPlan(this.planId);

  @override
  List<Object?> get props => [planId];
}

// States
abstract class SubscriptionState extends Equatable {
  const SubscriptionState();

  @override
  List<Object?> get props => [];
}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionLoading extends SubscriptionState {}

class SubscriptionLoaded extends SubscriptionState {
  final SubscriptionResponse data;
  final String selectedPlanId;

  const SubscriptionLoaded(this.data, this.selectedPlanId);

  @override
  List<Object?> get props => [data, selectedPlanId];

  SubscriptionPlan get selectedPlan =>
      data.plans.firstWhere((p) => p.id == selectedPlanId);
}

class SubscriptionError extends SubscriptionState {
  final String message;
  const SubscriptionError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final ISubscriptionRepository repository;

  SubscriptionBloc(this.repository) : super(SubscriptionInitial()) {
    on<LoadSubscriptionData>((event, emit) async {
      emit(SubscriptionLoading());
      try {
        final data = await repository.getSubscriptionData();
        emit(SubscriptionLoaded(data, 'yearly'));
      } catch (e) {
        emit(const SubscriptionError('Failed to load subscription plans'));
      }
    });

    on<SelectPlan>((event, emit) {
      if (state is SubscriptionLoaded) {
        final currentState = state as SubscriptionLoaded;
        emit(SubscriptionLoaded(currentState.data, event.planId));
      }
    });
  }
}
