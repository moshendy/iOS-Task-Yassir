import Foundation
import Combine

// MARK: - Get Characters Use Case Protocol
protocol GetCharactersUseCaseProtocol {
    func execute(page: Int, searchQuery: String?) -> AnyPublisher<CharacterResponse, AppError>
}

// MARK: - Get Characters Use Case Implementation
class GetCharactersUseCase: GetCharactersUseCaseProtocol {
    private let repository: CharacterRepositoryProtocol
    private let configuration: RepositoryConfiguration
    
    init(
        repository: CharacterRepositoryProtocol,
        configuration: RepositoryConfiguration = .default
    ) {
        self.repository = repository
        self.configuration = configuration
    }
    
    func execute(page: Int, searchQuery: String?) -> AnyPublisher<CharacterResponse, AppError> {
        // Validate input parameters
        guard page > 0 else {
            return Fail(error: AppError.invalidInput("Page number must be greater than 0"))
                .eraseToAnyPublisher()
        }
        
        // If search query is provided, validate it
        if let query = searchQuery, !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return repository.searchCharacters(query: query)
        }
        
        // Get characters for the specified page
        return repository.getCharacters(page: page, searchQuery: nil)
    }
}

// MARK: - Get Characters Use Case Factory
//class GetCharactersUseCaseFactory {
//    static func create() -> GetCharactersUseCase {
//        let repository = CharacterRepositoryFactory.create()
//        return GetCharactersUseCase(repository: repository)
//    }
//}
