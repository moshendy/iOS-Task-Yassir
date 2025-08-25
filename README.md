# Rick and Morty Character App

A modern iOS application built with SwiftUI that demonstrates clean architecture, MVVM pattern, and modern development practices. The app fetches character data from the Rick and Morty API with offline caching support and comprehensive testing infrastructure.

## Features

- **Character List**: Display characters with pagination (20 characters per page)
- **Search Functionality**: Search characters by name with real-time filtering
- **Character Details**: Comprehensive character information view
- **Offline Support**: Network-first caching strategy using Realm
- **Network Detection**: Real-time connectivity status monitoring
- **Comprehensive Testing**: tests covering unit, integration, and UI testing

## Technical Requirements

- **iOS**: 17.0+
- **Xcode**: 15.0+
- **Swift**: 5.9+

## Dependencies

- **Alamofire**: HTTP networking library
- **Combine**: Reactive programming framework
- **Kingfisher**: Image loading and caching
- **Realm**: Local database for offline caching

## Architecture

This project follows **Clean Architecture** principles with **MVVM** pattern:

### Layers

1. **Presentation Layer** (`Presentation/`)
   - Views and ViewModels
   - UI components and user interactions
   - SwiftUI views with MVVM pattern

2. **Domain Layer** (`Domain/`)
   - Entities: Core business objects
   - Use Cases: Business logic and rules
   - Repository Protocols: Data access contracts

3. **Data Layer** (`Data/`)
   - Network: API services and network management
   - Local: Database operations and caching
   - Repositories: Data source implementations

### Key Design Patterns

- **MVVM**: Separation of concerns between View and ViewModel
- **Repository Pattern**: Abstract data access layer
- **Use Case Pattern**: Business logic encapsulation
- **Observer Pattern**: Reactive updates using Combine
- **Dependency Injection**: Loose coupling between components

## Project Structure

```
YassirIOSTask/
├── App/                          # App configuration
├── Assets.xcassets/             # App assets and icons
├── ContentView.swift            # Main app entry point
├── YassirIOSTaskApp.swift       # App lifecycle
├── Domain/                      # Domain layer
│   ├── Entities/               # Core business objects
│   ├── UseCases/               # Business logic
│   └── Repositories/           # Data access contracts
├── Data/                       # Data layer
│   ├── Network/                # API services
│   ├── Local/                  # Database operations
│   └── Repositories/           # Data implementations
├── Presentation/               # Presentation layer
│   ├── Components/             # Reusable UI components
│   ├── DesignSystem/           # Design system components
│   └── Features/               # Feature-specific views
├── iOSTaskYassirTests/         # Unit test target
│   ├── ViewModels/            # ViewModel tests
│   ├── UseCases/              # Use case tests
│   ├── Repositories/          # Repository tests
│   ├── Mocks/                 # Mock objects for testing
│   └── Helpers/               # Test helper utilities
└── iOSTaskYassirUITests/      # UI test target
    ├── CharacterListView/     # List view UI tests
    ├── CharacterDetailsView/  # Details view UI tests
```

## Testing Infrastructure

This project includes a comprehensive testing strategy covering all architectural layers:

### Test Organization

#### **Unit Tests  - `iOSTaskYassirTests` target**
- **ViewModels **: Test presentation logic and user interactions
- **Use Cases **: Test business logic and rules
- **Repositories **: Test data access and caching logic

#### **UI Tests  - `iOSTaskYassirUITests` target**
- **CharacterListView **: Test list view functionality and search
- **CharacterDetailsView **: Test details view navigation and display


## Building and Running

### Prerequisites

1. Ensure you have Xcode 15.0 or later installed
2. Make sure you have iOS 17.0+ simulator or device

### Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/moshendy/iOS-Task-Yassir.git
   cd YassirIOSTask
   ```

2. **Open the project**
   - Open `YassirIOSTask.xcodeproj` in Xcode
   - Wait for Xcode to resolve dependencies

3. **Build and Run**
   - Select your target device/simulator
   - Press `Cmd + R` or click the Run button
   - The app should launch and start loading characters


### Troubleshooting

- **Build Errors**: Ensure all dependencies are properly resolved
- **Test Failures**: Check that mock data is properly configured
- **Network Issues**: Check your internet connection
- **Simulator Issues**: Try resetting the simulator (Device → Erase All Content and Settings)

## API Integration

The app integrates with the [Rick and Morty API](https://rickandmortyapi.com/):

- **Base URL**: `https://rickandmortyapi.com/api`
- **Endpoints**:
  - `GET /character` - List characters with pagination
  - `GET /character/{id}` - Get character details
  - `GET /character?name={query}` - Search characters by name

## Offline Caching Strategy

The app implements a **Network-First** caching strategy:

1. **Primary**: Attempt to fetch data from the network
2. **Fallback**: If network fails, serve cached data (if available)
3. **Update**: Cache is updated with fresh network data
4. **Expiration**: Cache expires after 1 hour

### Cache Behavior

- **Character List**: Cached for offline viewing
- **Search Results**: Not cached (requires network)
- **Character Details**: Fetched on-demand

## Network Connectivity

The app monitors network connectivity in real-time:

- **Connected**: Normal operation with live data
- **Disconnected**: Shows cached data with connectivity warning
- **Reconnection**: Automatically resumes normal operation

## Performance Considerations

- **Image Caching**: Kingfisher handles image loading and caching
- **Pagination**: Loads 20 characters at a time to minimize memory usage
- **Debounced Search**: 500ms delay to reduce API calls
- **Background Processing**: Network operations don't block UI

## Technical Decisions

### Why Clean Architecture?

- **Scalability**: Easy to add new features and modify existing ones
- **Testability**: Clear separation makes testing straightforward
- **Maintainability**: Code is organized and easy to understand
- **Independence**: Business logic is independent of external frameworks

### Why MVVM?

- **SwiftUI Integration**: Natural fit with SwiftUI's reactive nature
- **Separation of Concerns**: Clear distinction between UI and business logic
- **Testability**: ViewModels can be easily tested
- **Reactive Updates**: Combine integration for automatic UI updates

### Why Realm for Caching?

- **Performance**: Fast read/write operations
- **Swift Integration**: Native Swift support
- **Offline Capability**: Works without network connection
- **Automatic Updates**: Reactive data binding

### Why Comprehensive Testing?

- **Quality Assurance**: Ensures app behavior matches requirements
- **Regression Prevention**: Catches bugs before they reach production
- **Refactoring Safety**: Allows confident code changes and improvements
- **Documentation**: Tests serve as living documentation of app behavior
- **Performance Monitoring**: Tracks app performance over time

