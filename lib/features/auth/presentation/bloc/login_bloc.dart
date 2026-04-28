import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:art_mobile/core/config/service_locator.dart';
import 'package:art_mobile/features/auth/domain/repositories/auth_repository.dart';

// EVENTS
abstract class LoginEvent extends Equatable {
  const LoginEvent();
  @override
  List<Object> get props => [];
}

class PhoneNumberChanged extends LoginEvent {
  final String phoneNumber;
  const PhoneNumberChanged(this.phoneNumber);
  @override
  List<Object> get props => [phoneNumber];
}

class SendOtpPressed extends LoginEvent {}
class GoogleSignInPressed extends LoginEvent {}

// STATES
class LoginState extends Equatable {
  final String phoneNumber;
  final bool isLoading;
  final String? errorMessage;
  final bool isOtpSent;
  final bool isGoogleSuccess;
  final String? sessionId;

  const LoginState({
    this.phoneNumber = '',
    this.isLoading = false,
    this.errorMessage,
    this.isOtpSent = false,
    this.isGoogleSuccess = false,
    this.sessionId,
  });

  LoginState copyWith({
    String? phoneNumber,
    bool? isLoading,
    String? errorMessage,
    bool? isOtpSent,
    bool? isGoogleSuccess,
    String? sessionId,
  }) {
    return LoginState(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isOtpSent: isOtpSent ?? this.isOtpSent,
      isGoogleSuccess: isGoogleSuccess ?? this.isGoogleSuccess,
      sessionId: sessionId ?? this.sessionId,
    );
  }

  @override
  List<Object?> get props => [phoneNumber, isLoading, errorMessage, isOtpSent, isGoogleSuccess, sessionId];
}

// BLOC
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final IAuthRepository _authRepository = sl<IAuthRepository>();

  LoginBloc() : super(const LoginState()) {
    on<PhoneNumberChanged>((event, emit) => emit(state.copyWith(phoneNumber: event.phoneNumber, errorMessage: null)));
    
    on<SendOtpPressed>(_onSendOtp);
    on<GoogleSignInPressed>(_onGoogleSignIn);
  }

  Future<void> _onSendOtp(SendOtpPressed event, Emitter<LoginState> emit) async {
    if (state.phoneNumber.length < 10) return;
    
    emit(state.copyWith(isLoading: true, errorMessage: null));
    
    final result = await _authRepository.requestOtp(state.phoneNumber);
    
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (response) => emit(state.copyWith(
        isLoading: false, 
        isOtpSent: true,
        sessionId: response.data.sessionId,
      )),
    );
  }

  Future<void> _onGoogleSignIn(GoogleSignInPressed event, Emitter<LoginState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    
    // Google Sign In integration would call _authRepository.googleSignIn()
    await Future.delayed(const Duration(milliseconds: 1000));
    
    emit(state.copyWith(isLoading: false, isGoogleSuccess: true));
  }
}
