import Foundation

enum AppError: LocalizedError, Equatable {
    case networkError(String)
    case decodingError(String)
    case cacheError(String)
    case invalidInput(String)
    case unknownError(String)
    
    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network Error: \(message)"
        case .decodingError(let message):
            return "Data Error: \(message)"
        case .cacheError(let message):
            return "Cache Error: \(message)"
        case .invalidInput(let message):
            return "Invalid Input: \(message)"
        case .unknownError(let message):
            return "Unknown Error: \(message)"
        }
    }
    
    var failureReason: String? {
        switch self {
        case .networkError:
            return "Unable to connect to the server. Please check your internet connection."
        case .decodingError:
            return "Unable to process the data received from the server."
        case .cacheError:
            return "Unable to access local data storage."
        case .invalidInput:
            return "The provided input is not valid. Please check your input and try again."
        case .unknownError:
            return "An unexpected error occurred. Please try again."
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .networkError:
            return "Please check your internet connection and try again."
        case .cacheError:
            return "Please try restarting the app or contact support if the problem persists."
        case .decodingError:
            return "Please try refreshing the app or contact support if the problem persists."
        case .invalidInput:
            return "Please check your input and try again."
        case .unknownError:
            return "Please try again or contact support if the problem persists."
        }
    }
}
