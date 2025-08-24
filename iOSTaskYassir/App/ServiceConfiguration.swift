import Foundation

// MARK: - Simple Service Configuration
struct ServiceConfiguration {
    
    // MARK: - Service Registration
    static func configureServices() {
        let container = DIContainer.shared
        
        // Register all services
        container.register(NetworkManager.self, instance: NetworkManager.shared)
        container.register(CharacterAPIServiceProtocol.self, instance: CharacterAPIServiceFactory.create())
        container.register(RealmManagerProtocol.self, instance: RealmManagerFactory.create())
        container.register(CharacterRepositoryProtocol.self, instance: CharacterRepositoryFactory.create())
        container.register(GetCharactersUseCaseProtocol.self, instance: GetCharactersUseCaseFactory.create())
        container.register(GetCharacterDetailsUseCaseProtocol.self, instance: GetCharacterDetailsUseCaseFactory.create())
    }
}
