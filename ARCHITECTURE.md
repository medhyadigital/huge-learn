# Hindu Learning Platform - Architecture Design

## Overview
Production-grade Flutter mobile app for HUGE Foundations following Clean Architecture principles with Feature-first modularization.

## Architecture Principles

### 1. Clean Architecture Layers
- **Presentation Layer**: UI components, state management (BLoC), widgets
- **Domain Layer**: Business logic, entities, use cases, repository interfaces
- **Data Layer**: Repository implementations, data sources (API, local DB), models

### 2. Feature-First Modularization
Each feature is a self-contained module with its own:
- `presentation/` - UI and state management
- `domain/` - Business logic and entities
- `data/` - Data sources and repository implementations

### 3. Core Modules (Shared)
- `core/` - Common utilities, constants, errors, extensions
- `core_auth/` - HUGE Foundations User Auth integration
- `core_network/` - API client, interceptors, network utilities
- `core_storage/` - Local storage (SharedPreferences, Hive)
- `core_ui/` - Shared widgets, themes, design system

## Project Structure

```
lib/
├── core/                          # Core shared modules
│   ├── auth/                      # HUGE Foundations Auth integration
│   ├── network/                   # Network layer
│   ├── storage/                   # Local storage
│   ├── ui/                        # Shared UI components
│   ├── utils/                     # Utilities, extensions, constants
│   └── error/                     # Error handling
│
├── features/                      # Feature modules
│   ├── authentication/            # Auth feature (login, signup)
│   ├── onboarding/               # User onboarding
│   ├── home/                      # Home dashboard
│   ├── learning/                  # Learning content
│   ├── profile/                   # User profile
│   └── ...                        # Other features
│
└── main.dart                      # App entry point
```

## Technology Stack

### Core Dependencies
- **State Management**: `flutter_bloc` (BLoC pattern)
- **Dependency Injection**: `get_it` + `injectable`
- **Networking**: `dio` with interceptors
- **Local Storage**: `hive` (fast, lightweight) + `shared_preferences`
- **Code Generation**: `build_runner`, `injectable_generator`
- **Routing**: `go_router` (declarative routing)

### Performance Optimizations
- **Image Caching**: `cached_network_image`
- **Lazy Loading**: `ListView.builder`, pagination
- **Code Splitting**: Feature modules as separate packages
- **Memory Management**: Dispose controllers, avoid memory leaks
- **Build Optimization**: `--split-debug-info`, `--obfuscate`

## Authentication Architecture

### HUGE Foundations User Auth Integration
- **Auth Service**: Wrapper around HUGE Foundations auth API
- **Token Management**: Secure storage of auth tokens
- **Session Management**: Auto-refresh, logout handling
- **Auth State**: Global auth state using BLoC

## Learning Platform Data Architecture

### Separate Database & APIs
- **API Client**: Dedicated client for Learning Platform APIs
- **Repository Pattern**: Abstract data access layer
- **Local Cache**: Offline-first approach with Hive
- **Data Models**: Separate from auth models

## Performance Considerations

### Low-End Android Optimization
1. **Minimize Widget Rebuilds**: Use `const` constructors, `RepaintBoundary`
2. **Image Optimization**: Compress images, use appropriate formats
3. **Lazy Loading**: Load content on-demand
4. **Memory Management**: Dispose resources, avoid memory leaks
5. **Build Size**: Tree-shaking, code splitting
6. **Startup Time**: Defer non-critical initialization

## User Experience

### First-Time User Considerations
1. **Onboarding Flow**: Clear introduction to app features
2. **Simple Navigation**: Bottom navigation, clear labels
3. **Loading States**: Skeleton screens, progress indicators
4. **Error Handling**: User-friendly error messages
5. **Offline Support**: Graceful degradation

## Development Guidelines

1. **Code Organization**: Feature-first, not layer-first
2. **Dependency Rule**: Dependencies point inward (Domain ← Data ← Presentation)
3. **Testing**: Unit tests for use cases, widget tests for UI
4. **Documentation**: Clear comments, README per feature
5. **Code Style**: Follow Flutter/Dart style guide




