# Optimal Flutter Clean Architecture File Layout

For a Flutter app following **Clean Code** and **SOLID** principles with `flutter_bloc`, here's the recommended structure:

## Directory Structure

```
lib/
├── core/
│   ├── error/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── usecases/
│   │   └── usecase.dart
│   ├── network/
│   │   └── network_info.dart
│   ├── utils/
│   │   ├── constants.dart
│   │   └── validators.dart
│   └── di/
│       └── injection_container.dart
│
├── features/
│   └── [feature_name]/
│       ├── data/
│       │   ├── datasources/
│       │   │   ├── [feature]_local_datasource.dart
│       │   │   └── [feature]_remote_datasource.dart
│       │   ├── models/
│       │   │   └── [feature]_model.dart
│       │   └── repositories/
│       │       └── [feature]_repository_impl.dart
│       │
│       ├── domain/
│       │   ├── entities/
│       │   │   └── [feature]_entity.dart
│       │   ├── repositories/
│       │   │   └── [feature]_repository.dart
│       │   └── usecases/
│       │       ├── get_[feature].dart
│       │       └── update_[feature].dart
│       │
│       └── presentation/
│           ├── bloc/
│           │   ├── [feature]_bloc.dart
│           │   ├── [feature]_event.dart
│           │   └── [feature]_state.dart
│           ├── pages/
│           │   └── [feature]_page.dart
│           └── widgets/
│               ├── [feature]_widget.dart
│               └── [feature]_list_item.dart
│
└── main.dart
```

## Key Principles

### 1. **Dependency Rule** (Uncle Bob's Core Principle)
```
Presentation → Domain ← Data
```
- **Domain** is the innermost layer (pure Dart, no Flutter dependencies)
- **Data** and **Presentation** depend on Domain
- Domain knows **nothing** about outer layers

### 2. **Layer Responsibilities**

**Domain Layer** (Business Logic)
- **Entities**: Pure business objects
- **Repository Interfaces**: Contracts (abstractions)
- **Use Cases**: Single-responsibility business rules

**Data Layer** (Data Management)
- **Models**: Data representations (extend Entities)
- **Data Sources**: Remote (API) and Local (DB/Cache)
- **Repository Implementations**: Implement domain contracts

**Presentation Layer** (UI)
- **BLoC/Cubit**: State management
- **Pages**: Screen-level widgets
- **Widgets**: Reusable UI components

### 3. **Feature-First Organization**
Each feature is self-contained with all three layers, promoting:
- **Single Responsibility** (feature encapsulation)
- **Open/Closed** (easy to extend new features)
- Easier navigation and maintenance

## Example Structure for a "User Profile" Feature

```
lib/
├── core/
│   ├── error/
│   │   ├── exceptions.dart          // DataSourceException, ServerException
│   │   └── failures.dart            // Failure, ServerFailure, CacheFailure
│   ├── usecases/
│   │   └── usecase.dart             // abstract UseCase<Type, Params>
│   └── di/
│       └── injection_container.dart  // GetIt setup
│
├── features/
│   └── user_profile/
│       ├── data/
│       │   ├── datasources/
│       │   │   ├── user_profile_remote_datasource.dart
│       │   │   └── user_profile_local_datasource.dart
│       │   ├── models/
│       │   │   └── user_profile_model.dart
│       │   └── repositories/
│       │       └── user_profile_repository_impl.dart
│       │
│       ├── domain/
│       │   ├── entities/
│       │   │   └── user_profile.dart
│       │   ├── repositories/
│       │   │   └── user_profile_repository.dart
│       │   └── usecases/
│       │       ├── get_user_profile.dart
│       │       └── update_user_profile.dart
│       │
│       └── presentation/
│           ├── bloc/
│           │   ├── user_profile_bloc.dart
│           │   ├── user_profile_event.dart
│           │   └── user_profile_state.dart
│           ├── pages/
│           │   └── user_profile_page.dart
│           └── widgets/
│               ├── profile_avatar.dart
│               └── profile_info_card.dart
│
└── main.dart
```

## Benefits of This Structure

✅ **Testability**: Each layer can be tested independently  
✅ **Maintainability**: Easy to locate and modify code  
✅ **Scalability**: Add features without affecting others  
✅ **SOLID Compliance**: Clear separation of concerns  
✅ **Team Collaboration**: Multiple devs can work on different features simultaneously  

## Questions for Your Project

To provide more specific guidance:

1. **What type of app are you building?** (e.g., social, e-commerce, productivity)
2. **How many major features do you anticipate?**
3. **Are you using a backend API, local storage, or both?**
4. **Do you need shared state across multiple features?**

This will help me tailor the structure to your specific needs!