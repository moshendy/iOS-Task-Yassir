import Foundation
import Combine

// MARK: - Character API Service Protocol
protocol CharacterAPIServiceProtocol {
    func getCharacters(page: Int, searchQuery: String?) -> AnyPublisher<CharacterResponseDTO, AppError>
    func getCharacterDetails(id: Int) -> AnyPublisher<CharacterDTO, AppError>
}

// MARK: - Character API Service Implementation
class CharacterAPIService: CharacterAPIServiceProtocol {
    private let networkManager: NetworkManager
    private let baseURL = AppConfiguration.API.baseURL
    
    init(networkManager: NetworkManager = NetworkManager.shared) {
        self.networkManager = networkManager
    }
    
    func getCharacters(page: Int, searchQuery: String?) -> AnyPublisher<CharacterResponseDTO, AppError> {
        var parameters: [String: Any] = ["page": page]
        if let searchQuery = searchQuery, !searchQuery.isEmpty {
            parameters["name"] = searchQuery
        }
        
        let url = "\(baseURL)/character"
        return networkManager.request(url, parameters: parameters)
    }
    
    func getCharacterDetails(id: Int) -> AnyPublisher<CharacterDTO, AppError> {
        let url = "\(baseURL)/character/\(id)"
        return networkManager.request(url)
    }
}

// MARK: - Character API Service Factory
class CharacterAPIServiceFactory {
    static func create() -> CharacterAPIService {
        return CharacterAPIService()
    }
}
