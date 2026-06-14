import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:art_mobile/core/config/service_locator.dart';
import 'package:art_mobile/core/network/api_client.dart';
import 'package:art_mobile/core/storage/secure_storage_service.dart';

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
class SplashCompleted extends SplashState {
  final bool isLoggedIn;
  
  const SplashCompleted({this.isLoggedIn = false});

  @override
  List<Object> get props => [isLoggedIn];
}

// BLOC
class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final SecureStorageService _storageService = sl<SecureStorageService>();
  final ApiClient _apiClient = sl<ApiClient>();

  SplashBloc() : super(SplashInitial()) {
    on<StartSplashTimer>(_onStartTimer);
  }

  Future<void> _onStartTimer(StartSplashTimer event, Emitter<SplashState> emit) async {
    emit(SplashLoading());
    
    // Run auth check and the minimum splash timer concurrently
    final userDataFuture = _storageService.getUserData();
    final tokenFuture = _storageService.getAccessToken();
    final timerFuture = Future.delayed(const Duration(milliseconds: 2800));
    
    final results = await Future.wait([userDataFuture, tokenFuture, timerFuture]);
    final userData = results[0];
    final accessToken = results[1];

    if (userData != null && accessToken != null && accessToken.isNotEmpty) {
      // Verify the token is still valid with the backend
      try {
        await _apiClient.get(
          'profile',
          options: Options(
            sendTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 5),
          ),
        );
        emit(SplashCompleted(isLoggedIn: true));
      } on DioException catch (e) {
        if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
          await _storageService.clearAll();
          emit(SplashCompleted(isLoggedIn: false));
        } else {
          emit(SplashCompleted(isLoggedIn: true));
        }
      }
    } else {
      emit(SplashCompleted(isLoggedIn: false));
    }
  }
}
