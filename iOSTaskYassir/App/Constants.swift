import Foundation

// MARK: - App Constants
struct AppConstants {
    
    // MARK: - Pagination
    struct Pagination {
        static let defaultPageSize = 20
    }
    
    // MARK: - Cache
    struct Cache {
        static let defaultExpirationTime: TimeInterval = 3600 // 1 hour
    }

}
