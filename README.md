# Learning App - Flutter Professional Architecture

A production-ready learning app (similar to Coursera) built with Flutter, featuring video streaming, clean architecture, BLoC state management, and clean separation of concerns.

## Project Structure

```
lib/
├── core/                          # Shared code and utilities
│   ├── config/
│   │   ├── environment.dart       # Environment configuration
│   │   └── service_locator.dart   # Dependency injection setup
│   ├── constants/
│   │   └── app_constants.dart     # App-wide constants
│   ├── errors/
│   │   └── failures.dart          # Custom failure types
│   ├── models/
│   │   └── base_models.dart       # Base classes for entities and models
│   ├── network/
│   │   ├── api_client.dart        # HTTP client wrapper
│   │   └── interceptors/
│   │       ├── auth_interceptor.dart
│   │       └── error_interceptor.dart
│   ├── routing/
│   │   └── app_router.dart        # Go Router configuration
│   ├── theme/
│   │   ├── theme_colors.dart      # Color palette
│   │   └── theme_manager.dart     # Theme configuration
│   ├── utils/
│   │   └── app_utils.dart         # Utility functions
│   └── widgets/
│       └── common_widgets.dart    # Reusable widgets
│
├── features/                      # Feature modules
│   ├── auth/                      # Authentication feature
│   │   ├── data/
│   │   │   ├── datasources/       # API calls
│   │   │   ├── models/            # Data models (DTOs)
│   │   │   └── repositories/      # Repository implementations
│   │   ├── domain/
│   │   │   ├── entities/          # Business entities
│   │   │   ├── repositories/      # Repository abstractions
│   │   │   └── usecases/          # Business logic
│   │   └── presentation/
│   │       ├── bloc/              # State management
│   │       ├── pages/             # Screen widgets
│   │       └── widgets/           # Feature widgets
│   │
│   ├── home/                      # Home feature
│   ├── courses/                   # Courses listing feature
│   ├── video_player/              # Video streaming feature
│   ├── subscriptions/             # Subscription management
│   ├── profile/                   # User profile
│   ├── notifications/             # Push notifications
│   ├── activity/                  # Learning activity tracking
│   └── admin/                     # Admin features
│       ├── dashboard/
│       ├── users/
│       ├── videos/
│       ├── courses/
│       ├── reports/
│       ├── coupons/
│       ├── analytics/
│       ├── moderation/
│       ├── support/
│       └── roles/
│
├── app.dart                       # App configuration
└── main.dart                      # Entry point
```

## Architecture Principles

### Clean Architecture

- **Domain Layer**: Pure Dart, no Flutter imports. Contains entities, repositories (abstractions), and use cases.
- **Data Layer**: Implementation of repositories, models (DTOs), and data sources (API, cache, local storage).
- **Presentation Layer**: Flutter UI, BLoC state management, and widgets.

### State Management with BLoC

- One BLoC/Cubit per feature or subfeature
- Events represent user intents
- States represent UI states (Initial, Loading, Loaded, Error, etc.)
- Clear separation: UI listens to states, emits events

### Feature-First Structure

- Each feature is self-contained with its own layers
- Easy to test, scale, and maintain
- Minimal coupling between features

## Key Dependencies

### State Management

- `flutter_bloc: ^8.1.6` - BLoC pattern implementation
- `bloc: ^8.1.6` - BLoC core library

### Networking

- `dio: ^5.6.0` - HTTP client with interceptor support
- `pretty_dio_logger: ^1.3.1` - Request/response logging

### Local Storage

- `shared_preferences: ^2.2.3` - Simple key-value storage
- `flutter_secure_storage: ^9.2.2` - Secure token storage
- `hive: ^2.2.3` - Local NoSQL database
- `hive_flutter: ^1.1.0` - Hive for Flutter

### Video Streaming

- `video_player: ^2.10.0` - Native video player
- `chewie: ^1.8.1` - Video player UI wrapper
- `hls_parser: ^0.6.0` - HLS streaming support

### UI & Design

- `google_fonts: ^6.1.0` - Google fonts
- `flutter_svg: ^2.0.10` - SVG support
- `lottie: ^3.1.2` - Animations
- `shimmer: ^3.0.0` - Skeleton loaders
- `animations: ^2.1.0` - Page transitions

### Other

- `go_router: ^14.2.17` - Navigation and routing
- `get_it: ^7.6.4` - Service locator for DI
- `logger: ^2.1.0` - Logging
- `intl: ^0.19.0` - Internationalization

## Getting Started

### 1. Install Flutter

```bash
flutter --version
```

### 2. Get Dependencies

```bash
flutter pub get
```

### 3. Run the App

```bash
flutter run
```

### 4. Build for Release

```bash
flutter build apk      # For Android
flutter build ipa      # For iOS
```

## Creating a New Feature

### Step 1: Create Feature Folder Structure

```bash
mkdir -p lib/features/my_feature/{data/{datasources,models,repositories},domain/{entities,repositories,usecases},presentation/{bloc,pages,widgets}}
```

### Step 2: Start with Domain Layer

- Create entity in `domain/entities/`
- Create repository abstraction in `domain/repositories/`
- Create use cases in `domain/usecases/`

### Step 3: Implement Data Layer

- Create model in `data/models/` (converts API response to entity)
- Create data source in `data/datasources/` (handles API calls)
- Implement repository in `data/repositories/`

### Step 4: Build Presentation Layer

- Create events in `presentation/bloc/my_feature_event.dart`
- Create states in `presentation/bloc/my_feature_state.dart`
- Create BLoC in `presentation/bloc/my_feature_bloc.dart`
- Create pages in `presentation/pages/`
- Create widgets in `presentation/widgets/`

### Step 5: Add Routes

- Update `core/routing/app_router.dart` with new routes

## Naming Conventions

### Files & Classes

- Entities: `UserEntity`
- Models: `UserModel`
- Events: `LoginRequested`, `GetUserRequested`
- States: `AuthLoading`, `AuthSuccess`, `AuthError`
- BLoCs: `AuthBloc`, `CoursesBloc`
- Repositories: `AuthRepository`, `CourseRepository`
- Data sources: `AuthRemoteDataSource`, `AuthLocalDataSource`
- Pages: `LoginPage`, `HomePage`
- Widgets: `CourseCard`, `VideoTile`

### Constants

```dart
class AppConstants {
  static const String loginEndpoint = '/auth/login';
  static const int itemsPerPage = 10;
}
```

## Security Best Practices

1. **Token Storage**: Always use `FlutterSecureStorage` for tokens
2. **API Keys**: Never hardcode in the app, use backend proxy
3. **Input Validation**: Use `ValidationUtils` for all user input
4. **HTTPS Only**: Enforce in production environment
5. **Error Messages**: Show user-friendly messages, log technical details separately

## Testing

### Unit Tests

```bash
flutter test test/features/auth/domain/usecases/login_usecase_test.dart
```

### Widget Tests

```bash
flutter test test/features/auth/presentation/pages/login_page_test.dart
```

### Integration Tests

```bash
flutter test integration_test/app_test.dart
```

## Performance Tips

1. Use `const` widgets wherever possible
2. Implement lazy loading with `ListView.builder`
3. Cache images with `cached_network_image`
4. Use `Sliver` widgets for complex scrolls
5. Avoid heavy work in `build()` methods
6. Debounce search and API calls (500ms)

## Theming

### Light Theme

- Primary: `#1E5A96` (Blue)
- Accent: `#FF6B35` (Orange)
- Background: `#FAFAFA`

### Dark Theme

- Primary: `#1E5A96` (Blue)
- Accent: `#FF6B35` (Orange)
- Background: `#121212`

Switch themes via system settings or in-app toggle.

## Debugging

### Enable Debug Logs

```dart
// In main.dart
Logger().d('Debug message');
```

### Network Request Logs

```dart
// Automatically logged via ErrorInterceptor
```

### Bloc State Changes

```dart
// Enable BlocObserver for state tracking
Bloc.observer = MyBlocObserver();
```

## Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [BLoC Pattern](https://bloclibrary.dev)
- [Clean Architecture](https://resocoder.com/clean-architecture-tdd)
- [Dio Documentation](https://pub.dev/packages/dio)

## License

This project is licensed under the MIT License.

## Contributing

1. Create a feature branch
2. Follow the folder structure
3. Write tests for new features
4. Create a pull request

---
