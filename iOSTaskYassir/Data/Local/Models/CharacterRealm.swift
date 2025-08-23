import Foundation
import RealmSwift

// MARK: - Realm Data Model for Caching
class CharacterRealm: Object {
    @Persisted(primaryKey: true) var id: Int
    @Persisted var name: String
    @Persisted var status: String
    @Persisted var species: String
    @Persisted var type: String
    @Persisted var gender: String
    @Persisted var originName: String
    @Persisted var locationName: String
    @Persisted var image: String
    @Persisted var episodeUrls: String
    @Persisted var url: String
    @Persisted var created: String
    @Persisted var timestamp: Date
    
    convenience init(from character: Character) {
        self.init()
        self.id = character.id.value
        self.name = character.name.value
        self.status = character.status.value
        self.species = character.species.value
        self.type = character.type.value
        self.gender = character.gender.value
        self.originName = character.origin.name
        self.locationName = character.location.name
        self.image = character.image.url
        self.episodeUrls = character.episodes.map { $0.value }.joined(separator: ",")
        self.url = character.url.value
        self.created = character.created.formatted
        self.timestamp = Date()
    }
    
    func toDomain() -> Character {
        return Character(
            id: CharacterID(id),
            name: CharacterName(name),
            status: CharacterStatus(status),
            species: CharacterSpecies(species),
            type: CharacterType(type),
            gender: CharacterGender(gender),
            origin: CharacterLocation(name: originName, url: ""),
            location: CharacterLocation(name: locationName, url: ""),
            image: CharacterImage(image),
            episodes: episodeUrls.isEmpty ? [] : episodeUrls.components(separatedBy: ",").map { EpisodeID($0) },
            url: CharacterURL(url),
            created: CharacterCreatedDate(from: created)
        )
    }
}

// MARK: - Realm Configuration
extension CharacterRealm {
    static var configuration: Realm.Configuration {
        Realm.Configuration(
            schemaVersion: 1,
            migrationBlock: { _, _ in }
        )
    }
}
