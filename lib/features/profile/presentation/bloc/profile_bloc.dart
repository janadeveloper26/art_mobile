import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:art_mobile/core/config/service_locator.dart';
import 'package:art_mobile/core/storage/secure_storage_service.dart';
import 'package:art_mobile/features/auth/data/models/auth_models.dart';
import 'package:art_mobile/features/auth/domain/repositories/auth_repository.dart';

// EVENTS
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {
  const LoadProfile();
}

class UpdateProfile extends ProfileEvent {
  final String? name;
  final String? email;
  const UpdateProfile({this.name, this.email});
  @override
  List<Object?> get props => [name, email];
}

// STATES
class ProfileState extends Equatable {
  final UserData? user;
  final bool isLoading;
  final String? error;
  final bool updateSuccess;

  const ProfileState({
    this.user,
    this.isLoading = true,
    this.error,
    this.updateSuccess = false,
  });

  ProfileState copyWith({
    UserData? user,
    bool? isLoading,
    String? error,
    bool? updateSuccess,
  }) {
    return ProfileState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      updateSuccess: updateSuccess ?? this.updateSuccess,
    );
  }

  @override
  List<Object?> get props => [user, isLoading, error, updateSuccess];
}

// BLOC
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final IAuthRepository _authRepo = sl<IAuthRepository>();
  final SecureStorageService _storage = sl<SecureStorageService>();

  ProfileBloc() : super(const ProfileState()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
  }

  Future<void> _onLoadProfile(LoadProfile event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final result = await _authRepo.getProfile();
      await result.fold(
        (failure) async {
          final jsonStr = await _storage.getUserData();
          emit(state.copyWith(
            user: UserData.fromJsonString(jsonStr),
            isLoading: false,
            error: failure.message,
          ));
        },
        (user) async {
          emit(state.copyWith(user: user, isLoading: false));
        },
      );
    } catch (e) {
      final jsonStr = await _storage.getUserData();
      emit(state.copyWith(
        user: UserData.fromJsonString(jsonStr),
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateProfile(UpdateProfile event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(isLoading: true, error: null, updateSuccess: false));
    try {
      final result = await _authRepo.updateProfile(name: event.name, email: event.email);
      result.fold(
        (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
        (user) => emit(state.copyWith(user: user, isLoading: false, updateSuccess: true)),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
