import Foundation
import Combine

// MARK: - Character Repository Implementation
class CharacterRepository: CharacterRepositoryProtocol {
    private let apiService: CharacterAPIServiceProtocol
    private let realmManager: RealmManagerProtocol
    private let networkManager: any NetworkManagerProtocol
    private let configuration: RepositoryConfiguration
    
    init(
        apiService: CharacterAPIServiceProtocol = CharacterAPIServiceFactory.create(),
        realmManager: RealmManagerProtocol = RealmManagerFactory.create(),
        networkManager: any NetworkManagerProtocol = NetworkManager.shared,
        configuration: RepositoryConfiguration = .default
    ) {
        self.apiService = apiService
        self.realmManager = realmManager
        self.networkManager = networkManager
        self.configuration = configuration
    }
    
    // MARK: - Core Business Operations
    func getCharacters(page: Int, searchQuery: String?) -> AnyPublisher<CharacterResponse, AppError> {
        // Network-first approach with offline fallback
        return apiService.getCharacters(page: page, searchQuery: searchQuery)
            .map { $0.toDomain() }
            .handleEvents(receiveOutput: { [weak self] response in
                // Save to cache on successful network response
                self?.saveCharactersToCache(response.results)
            })
            .catch { [weak self] error -> AnyPublisher<CharacterResponse, AppError> in
                // If offline mode is disabled, return the error
                guard self?.configuration.enableOfflineMode == true else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
                
                // Try to return cached data as fallback
                return self?.getCachedCharactersResponse(page: page) ?? Fail(error: error).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func getCharacterDetails(id: CharacterID) -> AnyPublisher<Character, AppError> {
        return apiService.getCharacterDetails(id: id.value)
            .map { $0.toDomain() }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Search Operations
    func searchCharacters(query: String) -> AnyPublisher<CharacterResponse, AppError> {
        // Try network search first, fallback to cached search if offline
        return apiService.getCharacters(page: 1, searchQuery: query)
            .map { $0.toDomain() }
            .handleEvents(receiveOutput: { [weak self] response in
                // Save search results to cache
                self?.saveCharactersToCache(response.results)
            })
            .catch { [weak self] error -> AnyPublisher<CharacterResponse, AppError> in
                // If offline mode is disabled, return the error
                guard self?.configuration.enableOfflineMode == true else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
                
                // Try to search cached data as fallback
                return self?.searchCachedCharacters(query: query) ?? Fail(error: error).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    
    // MARK: - Private Helper Methods
    private func saveCharactersToCache(_ characters: [Character]) {
        realmManager.saveCharacters(characters)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }
    
    private func getCachedCharactersResponse(page: Int) -> AnyPublisher<CharacterResponse, AppError> {
        return realmManager.getCharacters()
            .map { cachedCharacters in
                // Create paginated response from cached data
                let startIndex = (page - 1) * AppConstants.Pagination.defaultPageSize
                let endIndex = min(startIndex + AppConstants.Pagination.defaultPageSize, cachedCharacters.count)
                
                // If requesting a page beyond available cached data, return empty
                if startIndex >= cachedCharacters.count {
                    return CharacterResponse(
                        info: PaginationInfo(
                            count: cachedCharacters.count,
                            pages: (cachedCharacters.count + AppConstants.Pagination.defaultPageSize - 1) / AppConstants.Pagination.defaultPageSize,
                            next: nil,
                            prev: nil
                        ),
                        results: []
                    )
                }
                
                let pageCharacters = Array(cachedCharacters[startIndex..<endIndex])
                let hasNextPage = endIndex < cachedCharacters.count
                
                return CharacterResponse(
                    info: PaginationInfo(
                        count: cachedCharacters.count,
                        pages: (cachedCharacters.count + AppConstants.Pagination.defaultPageSize - 1) / AppConstants.Pagination.defaultPageSize,
                        next: hasNextPage ? "next" : nil,
                        prev: page > 1 ? "prev" : nil
                    ),
                    results: pageCharacters
                )
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Private Helper Methods
    private func searchCachedCharacters(query: String) -> AnyPublisher<CharacterResponse, AppError> {
        return realmManager.getCharacters()
            .map { cachedCharacters in
                // Filter cached characters by name (case-insensitive search)
                let filteredCharacters = cachedCharacters.filter { character in
                    character.name.value.localizedCaseInsensitiveContains(query)
                }
                
                return CharacterResponse(
                    info: PaginationInfo(
                        count: filteredCharacters.count,
                        pages: 1, 
                        next: nil,
                        prev: nil
                    ),
                    results: filteredCharacters
                )
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Cancellables Management
    private var cancellables = Set<AnyCancellable>()
}

// MARK: - Character Repository Factory
class CharacterRepositoryFactory {
    static func create() -> CharacterRepositoryProtocol {
        return CharacterRepository()
    }
}
