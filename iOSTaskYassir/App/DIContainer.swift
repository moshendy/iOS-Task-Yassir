//
//  DIContainer.swift
//  iOSTaskYassir
//
//  Created by Mohamed Shendy on 24/08/2025.
//

import Foundation

// MARK: - Simple DI Container
class DIContainer {
    static let shared = DIContainer()
    
    private var services: [String: Any] = [:]
    
    private init() {}
    
    // MARK: - Simple Registration
    func register<T>(_ type: T.Type, instance: T) {
        let key = String(describing: type)
        services[key] = instance
    }
    
    // MARK: - Simple Resolution
    func resolve<T>(_ type: T.Type) -> T {
        let key = String(describing: type)
        
        guard let service = services[key] as? T else {
            fatalError("Service \(T.self) not registered. Make sure to register it first.")
        }
        
        return service
    }
    
    // MARK: - Convenience Method
    func resolve<T>() -> T {
        return resolve(T.self)
    }
}

// MARK: - Simple Service Locator
class ServiceLocator {
    internal let container = DIContainer.shared
    
    // MARK: - Public Services (used by ViewModels)
    var networkManager: NetworkManager {
        container.resolve(NetworkManager.self)
    }
    
    var getCharactersUseCase: GetCharactersUseCaseProtocol {
        container.resolve(GetCharactersUseCaseProtocol.self)
    }
    
    var getCharacterDetailsUseCase: GetCharacterDetailsUseCaseProtocol {
        container.resolve(GetCharacterDetailsUseCaseProtocol.self)
    }
    
    // MARK: - Internal Services (for debugging/testing)
    internal var characterAPIService: CharacterAPIServiceProtocol {
        container.resolve(CharacterAPIServiceProtocol.self)
    }
    
    internal var realmManager: RealmManagerProtocol {
        container.resolve(RealmManagerProtocol.self)
    }
    
    internal var characterRepository: CharacterRepositoryProtocol {
        container.resolve(CharacterRepositoryProtocol.self)
    }
    
    // MARK: - ViewModels
    @MainActor func createCharacterListViewModel() -> CharacterListViewModel {
        CharacterListViewModel(
            getCharactersUseCase: getCharactersUseCase,
            networkManager: networkManager,
            configuration: .default
        )
    }
    
    @MainActor func createCharacterDetailsViewModel(character: Character? = nil) -> CharacterDetailsViewModel {
        CharacterDetailsViewModel(
            character: character,
            getCharacterDetailsUseCase: getCharacterDetailsUseCase
        )
    }
    
    // MARK: - Global Access
    static let shared = ServiceLocator()
}
