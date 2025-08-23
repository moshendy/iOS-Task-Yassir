import Foundation
import Combine

// MARK: - Character Repository Protocol
protocol CharacterRepositoryProtocol {
    // MARK: - Core Business Operations
    func getCharacters(page: Int, searchQuery: String?) -> AnyPublisher<CharacterResponse, AppError>
    func getCharacterDetails(id: CharacterID) -> AnyPublisher<Character, AppError>
    
    // MARK: - Search Operations
    func searchCharacters(query: String) -> AnyPublisher<CharacterResponse, AppError>
    
    // MARK: - Pagination Support
    func hasMorePages(for currentPage: Int) -> Bool
    func getNextPage(after currentPage: Int) -> Int?
}

// MARK: - Repository Result Types
enum RepositoryResult<T> {
    case success(T)
    case failure(AppError)
    case cached(T)
}

// MARK: - Repository Configuration
struct RepositoryConfiguration {
    let charactersPerPage: Int
    let maxCacheAge: TimeInterval
    let enableOfflineMode: Bool
    
    static let `default` = RepositoryConfiguration(
        charactersPerPage: 20,
        maxCacheAge: 3600, // 1 hour
        enableOfflineMode: true
    )
}
