import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/subscription_model.dart';
import '../../domain/repositories/subscription_repository.dart';
import 'package:art_mobile/features/payment/domain/repositories/payment_repository.dart';
import 'package:art_mobile/features/payment/data/models/payment_models.dart';

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

class CreateSubscriptionOrder extends SubscriptionEvent {
  final String planId;
  const CreateSubscriptionOrder(this.planId);
  @override
  List<Object?> get props => [planId];
}

class VerifySubscriptionPayment extends SubscriptionEvent {
  final String razorpaySubscriptionId;
  final String razorpayPaymentId;
  final String razorpaySignature;

  const VerifySubscriptionPayment({
    required this.razorpaySubscriptionId,
    required this.razorpayPaymentId,
    required this.razorpaySignature,
  });

  @override
  List<Object?> get props => [razorpaySubscriptionId, razorpayPaymentId, razorpaySignature];
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
  final bool isProcessingPayment;
  final String? paymentError;
  final SubscriptionOrderResponse? createdOrder;
  final bool paymentSuccess;

  const SubscriptionLoaded({
    required this.data,
    required this.selectedPlanId,
    this.isProcessingPayment = false,
    this.paymentError,
    this.createdOrder,
    this.paymentSuccess = false,
  });

  @override
  List<Object?> get props => [data, selectedPlanId, isProcessingPayment, paymentError, createdOrder, paymentSuccess];

  SubscriptionPlan get selectedPlan =>
      data.plans.firstWhere((p) => p.id == selectedPlanId);

  SubscriptionLoaded copyWith({
    SubscriptionResponse? data,
    String? selectedPlanId,
    bool? isProcessingPayment,
    String? paymentError,
    SubscriptionOrderResponse? createdOrder,
    bool? paymentSuccess,
  }) {
    return SubscriptionLoaded(
      data: data ?? this.data,
      selectedPlanId: selectedPlanId ?? this.selectedPlanId,
      isProcessingPayment: isProcessingPayment ?? this.isProcessingPayment,
      paymentError: paymentError,
      createdOrder: createdOrder,
      paymentSuccess: paymentSuccess ?? this.paymentSuccess,
    );
  }
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
  final IPaymentRepository paymentRepository;

  SubscriptionBloc(this.repository, this.paymentRepository) : super(SubscriptionInitial()) {
    on<LoadSubscriptionData>((event, emit) async {
      emit(SubscriptionLoading());
      try {
        final data = await repository.getSubscriptionData();
        emit(SubscriptionLoaded(data: data, selectedPlanId: 'yearly'));
      } catch (e) {
        emit(const SubscriptionError('Failed to load subscription plans'));
      }
    });

    on<SelectPlan>((event, emit) {
      if (state is SubscriptionLoaded) {
        final currentState = state as SubscriptionLoaded;
        emit(currentState.copyWith(selectedPlanId: event.planId));
      }
    });

    on<CreateSubscriptionOrder>((event, emit) async {
      if (state is SubscriptionLoaded) {
        final currentState = state as SubscriptionLoaded;
        emit(currentState.copyWith(isProcessingPayment: true, paymentError: null, createdOrder: null));
        
        final result = await paymentRepository.createSubscription(event.planId);
        
        result.fold(
          (failure) => emit(currentState.copyWith(isProcessingPayment: false, paymentError: failure.message)),
          (order) => emit(currentState.copyWith(isProcessingPayment: false, createdOrder: order)),
        );
      }
    });

    on<VerifySubscriptionPayment>((event, emit) async {
      if (state is SubscriptionLoaded) {
        final currentState = state as SubscriptionLoaded;
        emit(currentState.copyWith(isProcessingPayment: true, paymentError: null, createdOrder: null));
        
        final result = await paymentRepository.verifySubscriptionPayment(
          razorpaySubscriptionId: event.razorpaySubscriptionId,
          razorpayPaymentId: event.razorpayPaymentId,
          razorpaySignature: event.razorpaySignature,
        );
        
        result.fold(
          (failure) => emit(currentState.copyWith(isProcessingPayment: false, paymentError: failure.message)),
          (_) => emit(currentState.copyWith(isProcessingPayment: false, paymentSuccess: true)),
        );
      }
    });
  }
}
