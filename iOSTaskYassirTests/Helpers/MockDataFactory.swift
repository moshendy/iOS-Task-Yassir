//
//  MockDataFactory.swift
//  YassirIOSTaskTests
//
//  Created by Mohamed Shendy on 24/08/2025.
//

import Foundation
@testable import iOSTaskYassir

// MARK: - Mock Data Factory
class MockDataFactory {
    
    // MARK: - Character Creation
    static func createMockCharacter(
        id: Int = 1,
        name: String = "Rick Sanchez",
        status: String = "alive",
        species: String = "Human",
        type: String = "",
        gender: String = "male",
        originName: String = "Earth",
        originURL: String = "https://rickandmortyapi.com/api/location/1",
        locationName: String = "Earth",
        locationURL: String = "https://rickandmortyapi.com/api/location/1",
        imageURL: String = "https://rickandmortyapi.com/api/character/avatar/1.jpeg",
        episodeURLs: [String] = ["https://rickandmortyapi.com/api/episode/1"],
        characterURL: String = "https://rickandmortyapi.com/api/character/1",
        createdDate: Date = Date()
    ) -> Character {
        return Character(
            id: CharacterID(id),
            name: CharacterName(name),
            status: CharacterStatus(status),
            species: CharacterSpecies(species),
            type: CharacterType(type),
            gender: CharacterGender(gender),
            origin: CharacterLocation(name: originName, url: originURL),
            location: CharacterLocation(name: locationName, url: locationURL),
            image: CharacterImage(imageURL),
            episodes: episodeURLs.map { EpisodeID($0) },
            url: CharacterURL(characterURL),
            created: CharacterCreatedDate(createdDate)
        )
    }
    
    // MARK: - Character List Creation
    static func createMockCharacterList(count: Int = 5) -> [Character] {
        return (1...count).map { index in
            createMockCharacter(
                id: index,
                name: "Character \(index)",
                status: index % 2 == 0 ? "alive" : "dead",
                species: index % 3 == 0 ? "Human" : "Alien"
            )
        }
    }
    
    // MARK: - Character Response Creation
    static func createMockCharacterResponse(
        characters: [Character] = createMockCharacterList(),
        page: Int = 1,
        totalPages: Int = 1
    ) -> CharacterResponse {
        return CharacterResponse(
            info: PaginationInfo(
                count: characters.count,
                pages: totalPages,
                next: page < totalPages ? "https://api.example.com/characters?page=\(page + 1)" : nil,
                prev: page > 1 ? "https://api.example.com/characters?page=\(page - 1)" : nil
            ),
            results: characters
        )
    }
    
    // MARK: - Error Creation
    static func createMockNetworkError() -> AppError {
        return .networkError("Mock network error")
    }
    
    static func createMockDecodingError() -> AppError {
        return .decodingError("Mock decoding error")
    }
    
    static func createMockCacheError() -> AppError {
        return .cacheError("Mock cache error")
    }
}
