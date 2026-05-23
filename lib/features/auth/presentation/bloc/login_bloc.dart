import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:art_mobile/core/config/service_locator.dart';
import 'package:art_mobile/features/auth/domain/repositories/auth_repository.dart';

// EVENTS
abstract class LoginEvent extends Equatable {
  const LoginEvent();
  @override
  List<Object?> get props => [];
}

class PhoneNumberChanged extends LoginEvent {
  final String phoneNumber;
  const PhoneNumberChanged(this.phoneNumber);
  @override
  List<Object?> get props => [phoneNumber];
}

class SendOtpPressed extends LoginEvent {}
class GoogleSignInPressed extends LoginEvent {}

class PhoneCodeSent extends LoginEvent {
  final String verificationId;
  const PhoneCodeSent(this.verificationId);
  @override
  List<Object?> get props => [verificationId];
}

class LoginFailed extends LoginEvent {
  final String message;
  const LoginFailed(this.message);
  @override
  List<Object?> get props => [message];
}

class GoogleSignInSuccess extends LoginEvent {}
class GoogleSignInPendingApproval extends LoginEvent {}

// STATES
class LoginState extends Equatable {
  final String phoneNumber;
  final bool isLoading;
  final String? errorMessage;
  final bool isOtpSent;
  final bool isGoogleSuccess;
  final bool isPendingApproval;
  final String? verificationId;

  const LoginState({
    this.phoneNumber = '',
    this.isLoading = false,
    this.errorMessage,
    this.isOtpSent = false,
    this.isGoogleSuccess = false,
    this.isPendingApproval = false,
    this.verificationId,
  });

  LoginState copyWith({
    String? phoneNumber,
    bool? isLoading,
    String? errorMessage,
    bool? isOtpSent,
    bool? isGoogleSuccess,
    bool? isPendingApproval,
    String? verificationId,
  }) {
    return LoginState(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isOtpSent: isOtpSent ?? this.isOtpSent,
      isGoogleSuccess: isGoogleSuccess ?? this.isGoogleSuccess,
      isPendingApproval: isPendingApproval ?? this.isPendingApproval,
      verificationId: verificationId ?? this.verificationId,
    );
  }

  @override
  List<Object?> get props => [
    phoneNumber, isLoading, errorMessage, 
    isOtpSent, isGoogleSuccess, isPendingApproval, 
    verificationId
  ];
}

// BLOC
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final IAuthRepository _authRepository = sl<IAuthRepository>();

  LoginBloc() : super(const LoginState()) {
    on<PhoneNumberChanged>((event, emit) => emit(state.copyWith(phoneNumber: event.phoneNumber, errorMessage: null)));
    
    on<SendOtpPressed>(_onSendOtp);
    on<GoogleSignInPressed>(_onGoogleSignIn);
    on<PhoneCodeSent>((event, emit) => emit(state.copyWith(
      isLoading: false, 
      isOtpSent: true, 
      verificationId: event.verificationId
    )));
    on<LoginFailed>((event, emit) => emit(state.copyWith(
      isLoading: false, 
      errorMessage: event.message
    )));
    on<GoogleSignInSuccess>((event, emit) => emit(state.copyWith(
      isLoading: false, 
      isGoogleSuccess: true
    )));
    on<GoogleSignInPendingApproval>((event, emit) => emit(state.copyWith(
      isLoading: false, 
      isPendingApproval: true
    )));
  }

  Future<void> _onSendOtp(SendOtpPressed event, Emitter<LoginState> emit) async {
    if (state.phoneNumber.length < 10) return;
    
    emit(state.copyWith(isLoading: true, errorMessage: null));
    
    final fullPhoneNumber = state.phoneNumber.startsWith('+') 
        ? state.phoneNumber 
        : '+91${state.phoneNumber}';
        
    final result = await _authRepository.sendOtp(
      phoneNumber: fullPhoneNumber,
      onCodeSent: (verificationId) {
        add(PhoneCodeSent(verificationId));
      },
    );

    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (_) {
        // Do nothing, wait for PhoneCodeSent event
      },
    );
  }

  Future<void> _onGoogleSignIn(GoogleSignInPressed event, Emitter<LoginState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    
    final result = await _authRepository.signInWithGoogle();
    
    result.fold(
      (failure) {
        if (failure.message.contains('pending admin approval')) {
          add(GoogleSignInPendingApproval());
        } else {
          add(LoginFailed(failure.message));
        }
      },
      (response) {
        add(GoogleSignInSuccess());
      },
    );
  }
}
