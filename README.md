# HUGE Learning Platform

Production-grade Hindu Learning Platform mobile app for HUGE Foundations built with Flutter.

## Architecture

This app follows **Clean Architecture** principles with **Feature-first modularization**:

- **Clean Architecture Layers**: Presentation → Domain → Data
- **Feature-First Organization**: Each feature is self-contained with its own layers
- **Separation of Concerns**: Clear boundaries between business logic, data, and UI

## Project Structure

```
lib/
├── core/                          # Core shared modules
│   ├── auth/                      # HUGE Foundations Auth integration
│   ├── network/                   # Network layer (Dio, interceptors)
│   ├── storage/                   # Local storage (SharedPreferences, Hive)
│   ├── ui/                        # Shared UI components & theme
│   ├── utils/                     # Utilities, extensions, constants
│   ├── error/                     # Error handling (failures, exceptions)
│   ├── di/                        # Dependency injection setup
│   └── routing/                   # App routing configuration
│
├── features/                      # Feature modules
│   ├── authentication/            # Auth feature (login, register, logout)
│   │   ├── presentation/          # UI & BLoC
│   │   ├── domain/                # Entities, use cases, repository interfaces
│   │   └── data/                  # Repository implementations, data sources
│   ├── onboarding/               # User onboarding
│   ├── home/                      # Home dashboard
│   ├── learning/                  # Learning content
│   └── profile/                   # User profile
│
└── main.dart                      # App entry point
```

## Technology Stack

### Core Dependencies
- **State Management**: `flutter_bloc` (BLoC pattern)
- **Dependency Injection**: `get_it`
- **Networking**: `dio` with interceptors
- **Local Storage**: `hive` + `shared_preferences`
- **Routing**: `go_router` (declarative routing)
- **Image Caching**: `cached_network_image`

### Performance Optimizations
- Lazy loading and pagination
- Image caching
- Efficient state management
- Memory leak prevention
- Optimized for low-end Android devices

## Setup Instructions

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd HUGE_Learning
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API endpoints**
   
   Update `lib/core/constants/app_constants.dart` with your API endpoints:
   ```dart
   static const String hugeFoundationsAuthBaseUrl = 'YOUR_AUTH_API_URL';
   static const String learningPlatformBaseUrl = 'YOUR_LEARNING_API_URL';
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## Features

### ✅ Implemented
- Clean Architecture structure
- Feature-first modularization
- Authentication module (login, register, logout)
- HUGE Foundations User Auth integration
- Network layer with error handling
- Local storage
- Dependency injection
- Basic UI components (loading, error, empty states)
- App theme configuration

### 🚧 In Progress / TODO
- Learning Platform data layer
- Onboarding flow
- Home dashboard
- Learning content features
- User profile
- Offline support
- Token refresh mechanism
- Navigation guards

## Development Guidelines

### Code Organization
1. **Feature-First**: Group related code by feature, not by layer
2. **Dependency Rule**: Dependencies point inward (Domain ← Data ← Presentation)
3. **Single Responsibility**: Each class/function should have one responsibility
4. **DRY**: Don't repeat yourself - use shared utilities

### Adding a New Feature

1. Create feature directory structure:
   ```
   lib/features/your_feature/
   ├── presentation/
   │   ├── bloc/
   │   ├── pages/
   │   └── widgets/
   ├── domain/
   │   ├── entities/
   │   ├── repositories/
   │   └── usecases/
   └── data/
       ├── models/
       ├── datasources/
       └── repositories/
   ```

2. Implement domain layer first (entities, repository interface, use cases)
3. Implement data layer (models, data sources, repository implementation)
4. Implement presentation layer (BLoC, UI)
5. Register dependencies in `lib/core/di/injection.dart`
6. Add routes in `lib/core/routing/app_router.dart`

### Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage
```

## Performance Considerations

### Low-End Android Optimization
1. **Minimize Widget Rebuilds**: Use `const` constructors, `RepaintBoundary`
2. **Image Optimization**: Compress images, use appropriate formats
3. **Lazy Loading**: Load content on-demand
4. **Memory Management**: Dispose resources, avoid memory leaks
5. **Build Size**: Tree-shaking, code splitting

## User Experience

### First-Time User Considerations
1. **Onboarding Flow**: Clear introduction to app features
2. **Simple Navigation**: Bottom navigation, clear labels
3. **Loading States**: Skeleton screens, progress indicators
4. **Error Handling**: User-friendly error messages
5. **Offline Support**: Graceful degradation

## API Integration

### Authentication (HUGE Foundations User Auth)
- Base URL: Configured in `AppConstants.hugeFoundationsAuthBaseUrl`
- Endpoints: `/login`, `/register`, `/logout`, `/refresh`, `/verify`
- Token Storage: Secure storage via `LocalStorage`

### Learning Platform
- Base URL: Configured in `AppConstants.learningPlatformBaseUrl`
- Separate API client for learning data
- Repository pattern for data access

## Contributing

1. Follow the architecture patterns established
2. Write tests for new features
3. Update documentation
4. Follow Flutter/Dart style guide

## License

[Your License Here]

## Contact

HUGE Foundations - [Your Contact Information]
