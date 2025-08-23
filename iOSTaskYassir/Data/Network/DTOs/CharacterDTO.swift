import Foundation

// MARK: - API Response DTOs
struct CharacterResponseDTO: Codable {
    let info: InfoDTO
    let results: [CharacterDTO]
}

struct InfoDTO: Codable {
    let count: Int
    let pages: Int
    let next: String?
    let prev: String?
}

struct CharacterDTO: Codable {
    let id: Int
    let name: String
    let status: String
    let species: String
    let type: String
    let gender: String
    let origin: LocationDTO
    let location: LocationDTO
    let image: String
    let episode: [String]
    let url: String
    let created: String
}

struct LocationDTO: Codable {
    let name: String
    let url: String
}

// MARK: - DTO to Domain Mapping
extension CharacterResponseDTO {
    func toDomain() -> CharacterResponse {
        let domainInfo = PaginationInfo(
            count: info.count,
            pages: info.pages,
            next: info.next,
            prev: info.prev
        )
        
        let domainCharacters = results.map { $0.toDomain() }
        
        return CharacterResponse(
            info: domainInfo,
            results: domainCharacters
        )
    }
}

extension CharacterDTO {
    func toDomain() -> Character {
        return Character(
            id: CharacterID(id),
            name: CharacterName(name),
            status: CharacterStatus(status),
            species: CharacterSpecies(species),
            type: CharacterType(type),
            gender: CharacterGender(gender),
            origin: CharacterLocation(name: origin.name, url: origin.url),
            location: CharacterLocation(name: location.name, url: location.url),
            image: CharacterImage(image),
            episodes: episode.map { EpisodeID($0) },
            url: CharacterURL(url),
            created: CharacterCreatedDate(from: created)
        )
    }
}
