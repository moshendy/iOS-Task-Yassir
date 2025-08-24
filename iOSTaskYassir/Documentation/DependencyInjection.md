# Dependency Injection System

This document explains how to use the new dependency injection system in the iOSTaskYassir app.

## Overview

The app now uses a robust dependency injection (DI) system that provides:
- **Type-safe dependency resolution**
- **Multiple scopes** (singleton, transient, weak)
- **Thread-safe container** with concurrent access
- **Easy testing** with mock injection
- **Service locator pattern** for convenient access

## Architecture

### Core Components

1. **DIContainer** - Main container for dependency registration and resolution
2. **ServiceLocator** - Convenient access to registered services
3. **ServiceConfiguration** - Centralized service registration
4. **MockDIContainer** - Testing support with mock injection

### Scopes

- **Singleton** - Single instance for the lifetime of the container
- **Transient** - New instance every time
- **Weak** - Weak reference, can be deallocated

## Usage

### 1. Service Registration

Services are automatically registered when the app starts:

```swift
// In iOSTaskYassirApp.swift
init() {
    ServiceConfiguration.configureServices()
}
```

### 2. Using Service Locator

```swift
// Get a service
let serviceLocator = ServiceLocator.shared
let networkManager = serviceLocator.networkManager
let characterRepository = serviceLocator.characterRepository

// Create ViewModels
let characterListVM = serviceLocator.createCharacterListViewModel()
let characterDetailsVM = serviceLocator.createCharacterDetailsViewModel()
```

### 3. Direct Container Access

```swift
let container = DIContainer.shared

// Register a service
container.registerSingleton(MyService.self) {
    MyService()
}

// Resolve a service
let myService: MyService = container.resolve()
```

### 4. Custom Service Registration

```swift
// Register with custom scope
container.register(MyService.self, factory: { MyService() }, scope: .transient)

// Register singleton
container.registerSingleton(MyService.self) { MyService() }

// Register weak reference
container.registerWeak(MyService.self) { MyService() }
```

## Testing

### Using Mock Container

```swift
class MyViewModelTests: XCTestCase {
    var mockContainer: MockDIContainer!
    var mockServiceLocator: MockServiceLocator!
    
    override func setUp() {
        super.setUp()
        mockContainer = MockDIContainer()
        mockServiceLocator = MockServiceLocator(container: mockContainer)
        
        // Register mocks
        mockContainer.registerMock(NetworkManager.self, mock: MockNetworkManager())
        mockContainer.registerMock(CharacterRepositoryProtocol.self, mock: MockCharacterRepository())
    }
    
    func testViewModelWithMocks() {
        // Your test implementation
    }
}
```

### Mock Injection

```swift
// Inject mock into service locator
mockServiceLocator.mockNetworkManager = MockNetworkManager()
mockServiceLocator.mockCharacterRepository = MockCharacterRepository()

// Use in tests
let viewModel = CharacterListViewModel(
    getCharactersUseCase: mockServiceLocator.getCharactersUseCase,
    networkManager: mockServiceLocator.networkManager,
    configuration: .default
)
```

## Best Practices

### 1. Service Registration

- **Register services** in `ServiceConfiguration.configureServices()`
- **Use appropriate scopes** for each service
- **Keep registration centralized** for easier maintenance

### 2. Service Resolution

- **Prefer ServiceLocator** for common use cases
- **Use direct container access** for custom scenarios
- **Handle resolution failures** gracefully

### 3. Testing

- **Use MockDIContainer** for unit tests
- **Inject mocks** through MockServiceLocator
- **Test different scopes** to ensure proper behavior

### 4. Performance

- **Singleton services** are cached and reused
- **Transient services** are created fresh each time
- **Weak references** help with memory management

## Migration from Old Factory Pattern

### Before (Old Factory)

```swift
class CharacterListViewModelFactory {
    static func create() -> CharacterListViewModel {
        return CharacterListViewModel(
            getCharactersUseCase: GetCharactersUseCaseFactory.create(),
            networkManager: NetworkManager.shared,
            configuration: .default
        )
    }
}
```

### After (DI-based Factory)

```swift
class CharacterListViewModelFactory {
    @MainActor static func create() -> CharacterListViewModel {
        let serviceLocator = ServiceLocator.shared
        
        return CharacterListViewModel(
            getCharactersUseCase: serviceLocator.getCharactersUseCase,
            networkManager: serviceLocator.networkManager,
            configuration: .default
        )
    }
}
```

## Benefits

1. **Better Testability** - Easy mock injection
2. **Loose Coupling** - Dependencies are injected, not hardcoded
3. **Centralized Configuration** - All services configured in one place
4. **Type Safety** - Compile-time dependency checking
5. **Performance** - Proper scoping and caching
6. **Maintainability** - Easy to change implementations

## Troubleshooting

### Common Issues

1. **"No factory registered" error**
   - Ensure service is registered in `ServiceConfiguration.configureServices()`
   - Check that registration happens before resolution

2. **Circular dependencies**
   - Use weak references or restructure dependencies
   - Consider using lazy initialization

3. **Memory leaks**
   - Use appropriate scopes (transient for ViewModels)
   - Avoid strong reference cycles

### Debug Tips

- Enable logging in debug builds
- Use breakpoints to trace dependency resolution
- Check service registration order
- Verify scope usage matches intended lifecycle
