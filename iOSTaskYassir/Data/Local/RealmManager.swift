import Foundation
import RealmSwift
import Combine

// MARK: - Realm Manager Protocol
protocol RealmManagerProtocol {
    func saveCharacters(_ characters: [Character]) -> AnyPublisher<Void, AppError>
    func getCharacters() -> AnyPublisher<[Character], AppError>
    func clearCache() -> AnyPublisher<Void, AppError>
    func isCacheValid() -> AnyPublisher<Bool, AppError>
}

// MARK: - Realm Manager Implementation
class RealmManager: RealmManagerProtocol {
    private var realm: Realm?
    private let configuration: Realm.Configuration?
    
    init(configuration: Realm.Configuration? = nil) {
        self.configuration = configuration
        setupRealm()
    }
    
    private func setupRealm() {
        do {
            let config = configuration ?? CharacterRealm.configuration
            realm = try Realm(configuration: config)
        } catch {
            print("Error setting up Realm: \(error)")
        }
    }
    
    func saveCharacters(_ characters: [Character]) -> AnyPublisher<Void, AppError> {
        return Future<Void, AppError> { promise in
            guard let realm = self.realm else {
                promise(.failure(.cacheError("Realm not initialized")))
                return
            }
            
            do {
                let characterRealms = characters.map { CharacterRealm(from: $0) }
                try realm.write {
                    realm.add(characterRealms, update: .modified)
                }
                promise(.success(()))
            } catch {
                promise(.failure(.cacheError("Failed to save characters: \(error.localizedDescription)")))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func getCharacters() -> AnyPublisher<[Character], AppError> {
        return Future<[Character], AppError> { promise in
            guard let realm = self.realm else {
                promise(.failure(.cacheError("Realm not initialized")))
                return
            }
            
            let characterRealms = realm.objects(CharacterRealm.self)
                .sorted(byKeyPath: "timestamp", ascending: false)
            
            let characters = Array(characterRealms.map { $0.toDomain() })
            promise(.success(characters))
        }
        .eraseToAnyPublisher()
    }
    
    func clearCache() -> AnyPublisher<Void, AppError> {
        return Future<Void, AppError> { promise in
            guard let realm = self.realm else {
                promise(.failure(.cacheError("Realm not initialized")))
                return
            }
            
            do {
                try realm.write {
                    realm.deleteAll()
                }
                promise(.success(()))
            } catch {
                promise(.failure(.cacheError("Failed to clear cache: \(error.localizedDescription)")))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func isCacheValid() -> AnyPublisher<Bool, AppError> {
        return Future<Bool, AppError> { promise in
            guard let realm = self.realm else {
                promise(.failure(.cacheError("Realm not initialized")))
                return
            }
            
            let characterRealms = realm.objects(CharacterRealm.self)
            guard let oldestCharacter = characterRealms.min(by: { $0.timestamp < $1.timestamp }) else {
                promise(.success(false))
                return
            }
            
            let cacheAge = Date().timeIntervalSince(oldestCharacter.timestamp)
            let isValid = cacheAge < AppConstants.Cache.defaultExpirationTime
            promise(.success(isValid))
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Realm Manager Factory
class RealmManagerFactory {
    static func create() -> RealmManagerProtocol {
        return RealmManager()
    }
}
