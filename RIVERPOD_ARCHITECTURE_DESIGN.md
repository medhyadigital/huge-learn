# HUGE Learning Platform - Flutter Architecture with Riverpod

## 🎯 Architecture Philosophy

This architecture is designed for:
- **Scalability**: Add new courses without touching core
- **Performance**: Optimized for low-end devices
- **Maintainability**: Clear separation of concerns
- **Testability**: Every layer independently testable
- **Offline-first**: Works without network

---

## 🏗️ Architecture Layers (Clean Architecture)

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│  • UI Widgets (Screens, Components)                          │
│  • State Notifiers (Riverpod)                                │
│  • View Models (Business logic for UI)                       │
│  • Controllers (User interaction handlers)                   │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                     DOMAIN LAYER                             │
│  • Entities (Core business objects)                          │
│  • Use Cases (Business rules)                                │
│  • Repository Interfaces (Contracts)                         │
│  • Value Objects (Validated data types)                      │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                      DATA LAYER                              │
│  • Repository Implementations                                │
│  • Data Sources (Remote API, Local Cache)                    │
│  • Models (Data transfer objects)                            │
│  • Mappers (Entity ↔ Model conversion)                       │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔧 Technology Choices & WHY

### 1. **Riverpod** (State Management)

**WHY Riverpod over BLoC:**
- ✅ **Better Performance**: No unnecessary rebuilds
- ✅ **Simpler**: Less boilerplate than BLoC
- ✅ **Compile-time Safety**: Catches errors at compile time
- ✅ **Better Testability**: Pure Dart objects, no widgets needed
- ✅ **Auto-dispose**: Automatic memory management
- ✅ **Family & AutoDispose**: Perfect for dynamic course/lesson lists

**When to use each Riverpod type:**
```dart
// Provider - Immutable, cached values
final apiClientProvider = Provider((ref) => ApiClient());

// StateProvider - Simple mutable state
final counterProvider = StateProvider((ref) => 0);

// StateNotifierProvider - Complex state with logic
final courseListProvider = StateNotifierProvider<CourseListNotifier, AsyncValue<List<Course>>>(
  (ref) => CourseListNotifier(ref.read(courseRepositoryProvider)),
);

// FutureProvider - Async data fetching
final courseDetailProvider = FutureProvider.family<Course, String>(
  (ref, courseId) => ref.read(courseRepositoryProvider).getCourseById(courseId),
);

// StreamProvider - Real-time data
final progressStreamProvider = StreamProvider.family<Progress, String>(
  (ref, courseId) => ref.read(progressRepositoryProvider).watchProgress(courseId),
);
```

### 2. **GoRouter** (Navigation)

**WHY GoRouter:**
- ✅ **Declarative**: Define routes as data
- ✅ **Type-safe**: No string-based navigation
- ✅ **Deep Linking**: URL-based navigation
- ✅ **Nested Navigation**: Tabs, bottom nav support
- ✅ **Redirect**: Auth guards, onboarding flows

**Example:**
```dart
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      if (authState == AuthState.unauthenticated) {
        return '/login';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/courses',
        builder: (context, state) => CoursesPage(),
        routes: [
          GoRoute(
            path: ':courseId',
            builder: (context, state) => CourseDetailPage(
              courseId: state.pathParameters['courseId']!,
            ),
          ),
        ],
      ),
    ],
  );
});
```

### 3. **Dio** (Networking)

**WHY Dio:**
- ✅ **Interceptors**: Auth, logging, retry logic
- ✅ **Timeout**: Configurable per request
- ✅ **Cancel**: Cancel in-flight requests
- ✅ **Progress**: Upload/download progress
- ✅ **FormData**: File uploads support

**Setup:**
```dart
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: AppConfig.apiBaseUrl,
    connectTimeout: Duration(seconds: 30),
    receiveTimeout: Duration(seconds: 30),
  ));
  
  // Auth interceptor
  dio.interceptors.add(AuthInterceptor(ref));
  
  // Retry interceptor
  dio.interceptors.add(RetryInterceptor());
  
  // Logger (debug only)
  if (kDebugMode) {
    dio.interceptors.add(LogInterceptor());
  }
  
  return dio;
});
```

### 4. **Hive** (Local Storage)

**WHY Hive:**
- ✅ **Fast**: NoSQL, key-value pairs
- ✅ **Lightweight**: ~1MB size
- ✅ **Encryption**: Built-in encryption support
- ✅ **Type-safe**: Using code generation
- ✅ **No Native Code**: Pure Dart

**Usage:**
```dart
// For caching API responses
@HiveType(typeId: 1)
class CourseCache extends HiveObject {
  @HiveField(0)
  final String courseId;
  
  @HiveField(1)
  final String jsonData;
  
  @HiveField(2)
  final DateTime cachedAt;
}

// For user progress (offline-first)
@HiveType(typeId: 2)
class LessonProgressCache extends HiveObject {
  @HiveField(0)
  final String lessonId;
  
  @HiveField(1)
  final double progressPercentage;
  
  @HiveField(2)
  final bool isCompleted;
  
  @HiveField(3)
  final bool needsSync; // Upload to server when online
}
```

### 5. **In-Memory Cache** (Performance)

**WHY:**
- ✅ **Speed**: Instant access
- ✅ **Reduce API Calls**: Cache frequently accessed data
- ✅ **Battery**: Less network = longer battery

**Implementation:**
```dart
class CacheManager {
  final _cache = <String, CachedItem>{};
  final _cacheDuration = Duration(minutes: 5);
  
  T? get<T>(String key) {
    final item = _cache[key];
    if (item == null) return null;
    
    if (DateTime.now().difference(item.timestamp) > _cacheDuration) {
      _cache.remove(key);
      return null;
    }
    
    return item.data as T;
  }
  
  void set<T>(String key, T data) {
    _cache[key] = CachedItem(data: data, timestamp: DateTime.now());
  }
}

final cacheManagerProvider = Provider((ref) => CacheManager());
```

---

## 📁 Project Structure (Feature-First)

```
lib/
├── core/                          # Core functionality
│   ├── constants/
│   │   ├── app_constants.dart     # App-wide constants
│   │   ├── api_endpoints.dart     # API URLs
│   │   └── asset_paths.dart       # Asset paths
│   │
│   ├── theme/
│   │   ├── app_theme.dart         # Theme data
│   │   ├── colors.dart            # Color palette
│   │   ├── typography.dart        # Text styles
│   │   └── spacing.dart           # Spacing constants
│   │
│   ├── widgets/                   # Reusable widgets
│   │   ├── buttons/
│   │   │   ├── primary_button.dart
│   │   │   └── secondary_button.dart
│   │   ├── cards/
│   │   │   ├── course_card.dart
│   │   │   └── lesson_card.dart
│   │   ├── loading/
│   │   │   ├── skeleton_loader.dart
│   │   │   └── shimmer_widget.dart
│   │   ├── empty_states/
│   │   │   └── empty_state_widget.dart
│   │   └── error/
│   │       └── error_widget.dart
│   │
│   ├── utils/
│   │   ├── extensions/            # Dart extensions
│   │   │   ├── string_extensions.dart
│   │   │   ├── date_extensions.dart
│   │   │   └── context_extensions.dart
│   │   ├── helpers/
│   │   │   ├── validation_helper.dart
│   │   │   ├── format_helper.dart
│   │   │   └── logger.dart
│   │   └── mixins/
│   │       └── connectivity_mixin.dart
│   │
│   ├── network/
│   │   ├── dio_client.dart        # Dio setup
│   │   ├── interceptors/
│   │   │   ├── auth_interceptor.dart
│   │   │   ├── retry_interceptor.dart
│   │   │   └── logging_interceptor.dart
│   │   └── network_info.dart      # Connectivity check
│   │
│   ├── cache/
│   │   ├── cache_manager.dart     # In-memory cache
│   │   ├── hive_service.dart      # Hive operations
│   │   └── models/
│   │       ├── course_cache.dart
│   │       └── progress_cache.dart
│   │
│   ├── error/
│   │   ├── failures.dart          # Failure types
│   │   ├── exceptions.dart        # Exception types
│   │   └── error_handler.dart     # Global error handling
│   │
│   └── providers/                 # Core providers
│       ├── dio_provider.dart
│       ├── hive_provider.dart
│       └── router_provider.dart
│
├── features/                      # Feature modules
│   │
│   ├── auth/                      # Authentication
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   ├── datasources/
│   │   │   │   ├── auth_remote_datasource.dart
│   │   │   │   └── auth_local_datasource.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── login_usecase.dart
│   │   │       └── logout_usecase.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── auth_provider.dart
│   │       ├── pages/
│   │       │   └── login_page.dart
│   │       └── widgets/
│   │           └── login_form.dart
│   │
│   ├── courses/                   # Course catalog
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── course_model.dart
│   │   │   │   ├── track_model.dart
│   │   │   │   └── school_model.dart
│   │   │   ├── datasources/
│   │   │   │   ├── course_remote_datasource.dart
│   │   │   │   └── course_local_datasource.dart
│   │   │   └── repositories/
│   │   │       └── course_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── course.dart
│   │   │   │   ├── track.dart
│   │   │   │   └── school.dart
│   │   │   ├── repositories/
│   │   │   │   └── course_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_schools_usecase.dart
│   │   │       ├── get_courses_usecase.dart
│   │   │       └── enroll_course_usecase.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   ├── schools_provider.dart
│   │       │   ├── courses_provider.dart
│   │       │   └── course_detail_provider.dart
│   │       ├── pages/
│   │       │   ├── schools_page.dart
│   │       │   ├── courses_page.dart
│   │       │   └── course_detail_page.dart
│   │       └── widgets/
│   │           ├── school_card.dart
│   │           ├── course_card.dart
│   │           └── course_header.dart
│   │
│   ├── learning/                  # Learning engine
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── lesson_model.dart
│   │   │   │   ├── module_model.dart
│   │   │   │   └── lesson_content_model.dart
│   │   │   ├── datasources/
│   │   │   │   ├── lesson_remote_datasource.dart
│   │   │   │   └── lesson_local_datasource.dart
│   │   │   └── repositories/
│   │   │       └── lesson_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── lesson.dart
│   │   │   │   ├── module.dart
│   │   │   │   └── lesson_content.dart
│   │   │   ├── repositories/
│   │   │   │   └── lesson_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_lesson_usecase.dart
│   │   │       ├── get_next_lesson_usecase.dart
│   │   │       └── preload_next_lesson_usecase.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   ├── lesson_provider.dart
│   │       │   ├── lesson_progress_provider.dart
│   │       │   └── module_provider.dart
│   │       ├── pages/
│   │       │   ├── module_page.dart
│   │       │   └── lesson_page.dart
│   │       └── widgets/
│   │           ├── renderers/       # Content renderers
│   │           │   ├── text_renderer.dart
│   │           │   ├── video_renderer.dart
│   │           │   ├── audio_renderer.dart
│   │           │   └── carousel_renderer.dart
│   │           ├── lesson_navigation.dart
│   │           └── progress_indicator.dart
│   │
│   ├── progress/                  # Progress tracking
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── progress_model.dart
│   │   │   │   └── enrollment_model.dart
│   │   │   ├── datasources/
│   │   │   │   ├── progress_remote_datasource.dart
│   │   │   │   └── progress_local_datasource.dart
│   │   │   └── repositories/
│   │   │       └── progress_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── progress.dart
│   │   │   │   └── enrollment.dart
│   │   │   ├── repositories/
│   │   │   │   └── progress_repository.dart
│   │   │   └── usecases/
│   │   │       ├── update_progress_usecase.dart
│   │   │       ├── get_progress_usecase.dart
│   │   │       └── sync_progress_usecase.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── progress_provider.dart
│   │       ├── pages/
│   │       │   └── progress_page.dart
│   │       └── widgets/
│   │           ├── progress_card.dart
│   │           └── progress_chart.dart
│   │
│   ├── quiz/                      # Quizzes & assessments
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── quiz_model.dart
│   │   │   │   └── question_model.dart
│   │   │   ├── datasources/
│   │   │   │   └── quiz_remote_datasource.dart
│   │   │   └── repositories/
│   │   │       └── quiz_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── quiz.dart
│   │   │   │   └── question.dart
│   │   │   ├── repositories/
│   │   │   │   └── quiz_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_quiz_usecase.dart
│   │   │       └── submit_quiz_usecase.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── quiz_provider.dart
│   │       ├── pages/
│   │       │   └── quiz_page.dart
│   │       └── widgets/
│   │           ├── question_widgets/
│   │           │   ├── mcq_widget.dart
│   │           │   ├── scenario_widget.dart
│   │           │   └── true_false_widget.dart
│   │           └── quiz_result_widget.dart
│   │
│   ├── gamification/              # XP, Karma, Badges
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── badge_model.dart
│   │   │   │   └── metrics_model.dart
│   │   │   ├── datasources/
│   │   │   │   ├── gamification_remote_datasource.dart
│   │   │   │   └── gamification_local_datasource.dart
│   │   │   └── repositories/
│   │   │       └── gamification_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── badge.dart
│   │   │   │   ├── metrics.dart
│   │   │   │   └── streak.dart
│   │   │   ├── repositories/
│   │   │   │   └── gamification_repository.dart
│   │   │   └── usecases/
│   │   │       ├── award_xp_usecase.dart
│   │   │       ├── award_karma_usecase.dart
│   │   │       ├── check_badge_usecase.dart
│   │   │       └── update_streak_usecase.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   ├── metrics_provider.dart
│   │       │   ├── badges_provider.dart
│   │       │   └── streak_provider.dart
│   │       ├── pages/
│   │       │   ├── badges_page.dart
│   │       │   └── leaderboard_page.dart
│   │       └── widgets/
│   │           ├── xp_bar.dart
│   │           ├── karma_display.dart
│   │           ├── badge_card.dart
│   │           └── streak_widget.dart
│   │
│   ├── ai_mentor/                 # AI recommendations
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── recommendation_model.dart
│   │   │   ├── datasources/
│   │   │   │   └── ai_remote_datasource.dart
│   │   │   └── repositories/
│   │   │       └── ai_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── recommendation.dart
│   │   │   ├── repositories/
│   │   │   │   └── ai_repository.dart
│   │   │   └── usecases/
│   │   │       └── get_recommendations_usecase.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── ai_mentor_provider.dart
│   │       ├── pages/
│   │       │   └── mentor_page.dart
│   │       └── widgets/
│   │           └── recommendation_card.dart
│   │
│   ├── profile/                   # User profile
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── learning_profile_model.dart
│   │   │   ├── datasources/
│   │   │   │   └── profile_remote_datasource.dart
│   │   │   └── repositories/
│   │   │       └── profile_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── learning_profile.dart
│   │   │   ├── repositories/
│   │   │   │   └── profile_repository.dart
│   │   │   └── usecases/
│   │   │       └── get_profile_usecase.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── profile_provider.dart
│   │       ├── pages/
│   │       │   └── profile_page.dart
│   │       └── widgets/
│   │           └── profile_header.dart
│   │
│   └── home/                      # Home dashboard
│       ├── presentation/
│       │   ├── providers/
│       │   │   └── home_provider.dart
│       │   ├── pages/
│       │   │   └── home_page.dart
│       │   └── widgets/
│       │       ├── continue_learning_card.dart
│       │       ├── featured_courses_section.dart
│       │       └── daily_streak_widget.dart
│       └── domain/
│           └── usecases/
│               └── get_home_data_usecase.dart
│
├── l10n/                          # Localization
│   ├── app_en.arb
│   ├── app_hi.arb
│   └── app_ta.arb
│
└── main.dart                      # App entry point
```

---

## 🔄 Data Flow (Unidirectional)

```
User Action (Tap, Scroll, Input)
         ↓
    UI Widget
         ↓
    Riverpod Provider (reads state)
         ↓
    Use Case (business logic)
         ↓
    Repository (data abstraction)
         ↓
    Data Source (API or Cache)
         ↓
    Model (DTO)
         ↓
    Entity (Domain object)
         ↓
    State Notifier (updates state)
         ↓
    Provider (notifies listeners)
         ↓
    UI Widget (rebuilds)
```

**Example Flow: Completing a Lesson**

```dart
// 1. User Action
onPressed: () => ref.read(lessonProgressProvider.notifier).completeLesson(lessonId)

// 2. State Notifier
class LessonProgressNotifier extends StateNotifier<AsyncValue<Progress>> {
  Future<void> completeLesson(String lessonId) async {
    state = const AsyncValue.loading();
    
    // 3. Use Case
    final result = await _completeLessonUseCase(lessonId);
    
    // 4. Update State
    result.when(
      success: (progress) => state = AsyncValue.data(progress),
      failure: (error) => state = AsyncValue.error(error, StackTrace.current),
    );
  }
}

// 5. UI Rebuilds
Consumer(builder: (context, ref, child) {
  final progress = ref.watch(lessonProgressProvider);
  
  return progress.when(
    data: (data) => Text('Progress: ${data.percentage}%'),
    loading: () => CircularProgressIndicator(),
    error: (error, stack) => ErrorWidget(error),
  );
})
```

---

## 📱 WHY This Structure Works

### 1. **Feature-First Organization**
- ✅ Each feature is self-contained
- ✅ Easy to add/remove features
- ✅ Teams can work on different features independently
- ✅ Clear ownership and boundaries

### 2. **Clean Architecture Layers**
- ✅ **Domain** is independent (no external dependencies)
- ✅ **Data** depends only on Domain
- ✅ **Presentation** depends only on Domain
- ✅ Easy to test each layer independently
- ✅ Can swap implementations (e.g., API → Mock)

### 3. **Riverpod Advantages**
- ✅ **No BuildContext**: Can use anywhere
- ✅ **Auto-dispose**: Memory efficient
- ✅ **Family**: Dynamic providers for courses, lessons
- ✅ **Computed State**: Derive state from other providers
- ✅ **Testing**: Pure functions, easy to test

### 4. **Offline-First**
- ✅ **Hive** for persistent cache
- ✅ **In-memory** for session cache
- ✅ **Sync Queue**: Upload progress when online
- ✅ **Optimistic Updates**: Instant UI feedback

### 5. **Scalability**
- ✅ Add new schools → Just add to `schools/` feature
- ✅ Add new lesson types → Just add renderer widget
- ✅ Add new languages → Just add .arb file
- ✅ Add new gamification → Just extend `gamification/` feature

---

## 🚀 Next Steps

1. Generate base project structure
2. Set up Riverpod providers
3. Implement core utilities
4. Create reusable widgets
5. Implement features one by one

**This architecture ensures:**
- ✅ Fast development
- ✅ Easy maintenance
- ✅ Excellent performance
- ✅ Future-proof design




