import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:art_mobile/core/config/service_locator.dart';
import 'package:art_mobile/core/services/device_service.dart';
import 'package:art_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:art_mobile/features/auth/data/models/auth_models.dart';
import 'package:art_mobile/features/auth/services/firebase_auth_service.dart';

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

class PhoneVerificationCompleted extends LoginEvent {
  final String idToken;
  const PhoneVerificationCompleted(this.idToken);
  @override
  List<Object?> get props => [idToken];
}

class PhoneVerificationFailed extends LoginEvent {
  final String message;
  const PhoneVerificationFailed(this.message);
  @override
  List<Object?> get props => [message];
}

class PhoneCodeSent extends LoginEvent {
  final String verificationId;
  final int? resendToken;
  const PhoneCodeSent(this.verificationId, this.resendToken);
  @override
  List<Object?> get props => [verificationId, resendToken];
}

// STATES
class LoginState extends Equatable {
  final String phoneNumber;
  final bool isLoading;
  final String? errorMessage;
  final bool isOtpSent;
  final bool isGoogleSuccess;
  final bool isPendingApproval;
  final String? sessionId;
  final String? verificationId;

  const LoginState({
    this.phoneNumber = '',
    this.isLoading = false,
    this.errorMessage,
    this.isOtpSent = false,
    this.isGoogleSuccess = false,
    this.isPendingApproval = false,
    this.sessionId,
    this.verificationId,
  });

  LoginState copyWith({
    String? phoneNumber,
    bool? isLoading,
    String? errorMessage,
    bool? isOtpSent,
    bool? isGoogleSuccess,
    bool? isPendingApproval,
    String? sessionId,
    String? verificationId,
  }) {
    return LoginState(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isOtpSent: isOtpSent ?? this.isOtpSent,
      isGoogleSuccess: isGoogleSuccess ?? this.isGoogleSuccess,
      isPendingApproval: isPendingApproval ?? this.isPendingApproval,
      sessionId: sessionId ?? this.sessionId,
      verificationId: verificationId ?? this.verificationId,
    );
  }

  @override
  List<Object?> get props => [
    phoneNumber, isLoading, errorMessage, 
    isOtpSent, isGoogleSuccess, isPendingApproval, 
    sessionId, verificationId
  ];
}

// BLOC
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final IAuthRepository _authRepository = sl<IAuthRepository>();
  final FirebaseAuthService _firebaseAuthService = sl<FirebaseAuthService>();
  final DeviceService _deviceService = sl<DeviceService>();

  LoginBloc() : super(const LoginState()) {
    on<PhoneNumberChanged>((event, emit) => emit(state.copyWith(phoneNumber: event.phoneNumber, errorMessage: null)));
    
    on<SendOtpPressed>(_onSendOtp);
    on<GoogleSignInPressed>(_onGoogleSignIn);
    on<PhoneCodeSent>((event, emit) => emit(state.copyWith(
      isLoading: false, 
      isOtpSent: true, 
      verificationId: event.verificationId
    )));
    on<PhoneVerificationFailed>((event, emit) => emit(state.copyWith(
      isLoading: false, 
      errorMessage: event.message
    )));
    on<PhoneVerificationCompleted>(_onPhoneVerificationCompleted);
  }

  Future<void> _onSendOtp(SendOtpPressed event, Emitter<LoginState> emit) async {
    if (state.phoneNumber.length < 10) return;
    
    emit(state.copyWith(isLoading: true, errorMessage: null));
    
    final fullPhoneNumber = state.phoneNumber.startsWith('+') 
        ? state.phoneNumber 
        : '+91${state.phoneNumber}';
        
    await _firebaseAuthService.verifyPhoneNumber(
      phoneNumber: fullPhoneNumber,
      codeSent: (verificationId, resendToken) {
        add(PhoneCodeSent(verificationId, resendToken));
      },
      verificationFailed: (e) {
        add(PhoneVerificationFailed(e.message ?? 'Verification failed'));
      },
      verificationCompleted: (credential) async {
        if (credential.smsCode != null) {
          // This happens on some Android devices with auto-verification
          final userCredential = await sl<FirebaseAuthService>().signInWithOtp(
            credential.verificationId!, 
            credential.smsCode!
          );
          if (userCredential != null) {
            add(PhoneVerificationCompleted(userCredential));
          }
        }
      },
      codeAutoRetrievalTimeout: (verificationId) {},
    );
  }

  Future<void> _onPhoneVerificationCompleted(PhoneVerificationCompleted event, Emitter<LoginState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    
    final deviceInfoMap = await _deviceService.getDeviceInfo();
    final device = DeviceMetadata(
      installId: deviceInfoMap['install_id'],
      platform: deviceInfoMap['platform'],
      deviceModel: deviceInfoMap['device_model'],
      osVersion: deviceInfoMap['os_version'],
      appVersion: deviceInfoMap['app_version'],
    );

    final result = await _authRepository.firebaseLogin(event.idToken, device);
    
    result.fold(
      (failure) {
        if (failure.message.contains('pending admin approval')) {
          emit(state.copyWith(isLoading: false, isPendingApproval: true));
        } else {
          emit(state.copyWith(isLoading: false, errorMessage: failure.message));
        }
      },
      (response) => emit(state.copyWith(isLoading: false, isGoogleSuccess: true)),
    );
  }

  Future<void> _onGoogleSignIn(GoogleSignInPressed event, Emitter<LoginState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    
    try {
      final idToken = await _firebaseAuthService.signInWithGoogle();
      if (idToken == null) {
        emit(state.copyWith(isLoading: false));
        return;
      }

      final deviceInfoMap = await _deviceService.getDeviceInfo();
      final device = DeviceMetadata(
        installId: deviceInfoMap['install_id'],
        platform: deviceInfoMap['platform'],
        deviceModel: deviceInfoMap['device_model'],
        osVersion: deviceInfoMap['os_version'],
        appVersion: deviceInfoMap['app_version'],
      );

      final result = await _authRepository.firebaseLogin(idToken, device);
      
      result.fold(
        (failure) {
          if (failure.message.contains('pending admin approval')) {
            emit(state.copyWith(isLoading: false, isPendingApproval: true));
          } else {
            emit(state.copyWith(isLoading: false, errorMessage: failure.message));
          }
        },
        (response) => emit(state.copyWith(isLoading: false, isGoogleSuccess: true)),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
