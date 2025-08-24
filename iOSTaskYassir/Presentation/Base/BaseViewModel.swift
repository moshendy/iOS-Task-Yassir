import Foundation
import Combine
import SwiftUI

// MARK: - Base ViewModel Protocol
protocol BaseViewModelProtocol: ObservableObject {
    var cancellables: Set<AnyCancellable> { get }
    func clearError()
}

// MARK: - Base ViewModel Implementation
class BaseViewModel: BaseViewModelProtocol {
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    var cancellables = Set<AnyCancellable>()
    
    init() {
        // setupBindings will be called by subclasses after super.init()
    }
    
    /// Setup any common bindings
    func setupBindings() {
        // Override in subclasses if needed
    }
    
    /// Clear the current error message
    func clearError() {
        DispatchQueue.main.async { [weak self] in
            self?.errorMessage = nil
        }
    }
    
    /// Handle errors with consistent error handling
    func handleError(_ error: AppError) {
        DispatchQueue.main.async { [weak self] in
            self?.errorMessage = error.localizedDescription
        }
    }
    
    /// Handle network errors specifically
    func handleNetworkError(_ error: AppError) {
        switch error {
        case .networkError:
            handleError(.networkError("No internet connection. Please check your connection and try again."))
        case .decodingError:
            handleError(.decodingError("Failed to process data. Please try again."))
        default:
            handleError(error)
        }
    }
    
    /// Clean up resources
    deinit {
        cancellables.removeAll()
    }
}

// MARK: - ViewModel Factory Protocol
protocol ViewModelFactoryProtocol {
    associatedtype ViewModelType
    static func create() -> ViewModelType
}

// MARK: - Base Factory Implementation
class BaseFactory<T> {
    static func create<U>(_ type: U.Type, factory: @escaping () -> U) -> U {
        return factory()
    }
}
