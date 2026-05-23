import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:art_mobile/core/config/service_locator.dart';
import 'package:art_mobile/features/auth/domain/repositories/auth_repository.dart';

// EVENTS
abstract class OtpEvent extends Equatable {
  const OtpEvent();
  @override
  List<Object?> get props => [];
}

class StartResendTimer extends OtpEvent {}
class ResendTimerTick extends OtpEvent {
  final int seconds;
  const ResendTimerTick(this.seconds);
  @override
  List<Object?> get props => [seconds];
}

class VerifyOtpPressed extends OtpEvent {
  final String otp;
  const VerifyOtpPressed(this.otp);
  @override
  List<Object?> get props => [otp];
}

class ResendOtpPressed extends OtpEvent {}

class OtpVerificationSuccess extends OtpEvent {}

class OtpVerificationFailed extends OtpEvent {
  final String message;
  const OtpVerificationFailed(this.message);
  @override
  List<Object?> get props => [message];
}

class OtpVerificationPendingApproval extends OtpEvent {}

// STATES
class OtpState extends Equatable {
  final int resendTimer;
  final bool isLoading;
  final bool isVerified;
  final bool isPendingApproval;
  final String? errorMessage;

  const OtpState({
    this.resendTimer = 30,
    this.isLoading = false,
    this.isVerified = false,
    this.isPendingApproval = false,
    this.errorMessage,
  });

  OtpState copyWith({
    int? resendTimer,
    bool? isLoading,
    bool? isVerified,
    bool? isPendingApproval,
    String? errorMessage,
  }) {
    return OtpState(
      resendTimer: resendTimer ?? this.resendTimer,
      isLoading: isLoading ?? this.isLoading,
      isVerified: isVerified ?? this.isVerified,
      isPendingApproval: isPendingApproval ?? this.isPendingApproval,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [resendTimer, isLoading, isVerified, isPendingApproval, errorMessage];
}

// BLOC
class OtpBloc extends Bloc<OtpEvent, OtpState> {
  final String phoneNumber;
  final String verificationId;
  final IAuthRepository _authRepository = sl<IAuthRepository>();
  Timer? _timer;

  OtpBloc({required this.phoneNumber, required this.verificationId}) : super(const OtpState()) {
    on<StartResendTimer>(_onStartTimer);
    on<ResendTimerTick>((event, emit) => emit(state.copyWith(resendTimer: event.seconds)));
    on<VerifyOtpPressed>(_onVerifyOtp);
    on<ResendOtpPressed>(_onResendOtp);
    on<OtpVerificationSuccess>((event, emit) => emit(state.copyWith(isLoading: false, isVerified: true)));
    on<OtpVerificationFailed>((event, emit) => emit(state.copyWith(isLoading: false, errorMessage: event.message)));
    on<OtpVerificationPendingApproval>((event, emit) => emit(state.copyWith(isLoading: false, isPendingApproval: true)));
  }

  void _onStartTimer(StartResendTimer event, Emitter<OtpState> emit) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.resendTimer > 0) {
        add(ResendTimerTick(state.resendTimer - 1));
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _onVerifyOtp(VerifyOtpPressed event, Emitter<OtpState> emit) async {
    if (event.otp.length < 6) {
      emit(state.copyWith(errorMessage: 'Please enter the complete 6-digit OTP'));
      return;
    }

    emit(state.copyWith(isLoading: true, errorMessage: null));
    
    final result = await _authRepository.verifyOtp(
      verificationId: verificationId,
      otp: event.otp,
    );
    
    result.fold(
      (failure) {
        if (failure.message.contains('pending admin approval')) {
          add(OtpVerificationPendingApproval());
        } else {
          add(OtpVerificationFailed(failure.message));
        }
      },
      (_) {
        add(OtpVerificationSuccess());
      },
    );
  }

  Future<void> _onResendOtp(ResendOtpPressed event, Emitter<OtpState> emit) async {
    emit(state.copyWith(resendTimer: 30, errorMessage: null));
    add(StartResendTimer());
    
    // We call sendOtp from repository but we might need a way to update verificationId in state.
    // For simplicity, we assume the same verificationId works or a new one is handled separately.
    await _authRepository.sendOtp(
      phoneNumber: phoneNumber,
      onCodeSent: (newVerificationId) {
        // If we want to handle new verificationId we would need a state update.
      },
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}

